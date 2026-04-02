;;; opencode-sdk.el --- SDK wrapping OpenCode HTTP API -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Diogo Doreto
;;
;; Author: Diogo Doreto <diogo@doreto.com.br>
;; Maintainer: Diogo Doreto <diogo@doreto.com.br>
;; Created: March 31, 2026
;; Modified: March 31, 2026
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc wp
;; Homepage: https://github.com/local_diogodoreto/opencode-sdk
;; Package-Requires: ((emacs "27.1") (plz "0.7"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  SDK wrapping OpenCode HTTP API
;;
;;; Code:

(require 'plz)
(require 'json)

;;; Customization Group

(defgroup opencode-sdk nil
  "SDK for interacting with the OpenCode HTTP API."
  :group 'tools
  :prefix "opencode-sdk-")

;;; Configuration

(defcustom opencode-sdk-base-url "http://localhost:4242"
  "Base URL of the running OpenCode HTTP server."
  :type 'string
  :group 'opencode-sdk)

;;; Internal HTTP Helper

(defun opencode-sdk--request (method path &optional params body callback)
  "Issue an async HTTP request using `plz'.

METHOD is a symbol like `get' or `post'.
PATH is the URL path string (e.g. \"/session\").
PARAMS is an optional alist of query parameters.
BODY is an optional request body (will be JSON-encoded if non-nil).
CALLBACK is called with (RESULT ERROR) where RESULT is the parsed JSON
alist on success and ERROR is a string on failure."
  (let* ((query-string (when params
                         (url-build-query-string params)))
         (url (if query-string
                  (concat opencode-sdk-base-url path "?" query-string)
                (concat opencode-sdk-base-url path)))
         (encoded-body (when body
                         (json-encode body)))
         (headers `(("Content-Type" . "application/json"))))
    (condition-case err
        (plz method url
          :headers headers
          :body encoded-body
          :as #'json-read
          :then (lambda (result)
                  (when callback
                    (funcall callback result nil)))
          :else (lambda (err)
                  (when callback
                    (funcall callback nil (format "Request error: %s" (error-message-string err))))))
      (error
       (when callback
         (funcall callback nil (format "Request error: %s" (error-message-string err))))))))

;;; Internal Helpers

(defun opencode-sdk--normalize-directory (directory)
  "Return DIRECTORY with any trailing slash removed.

Emacs functions such as `project-root' and `default-directory' return directory
paths with a trailing slash by convention (e.g. \"/home/user/project/\").  The
OpenCode API expects paths without a trailing slash (e.g.
\"/home/user/project\").  This helper adapts Emacs-convention paths to the API's
expectation so that callers may pass paths from standard Emacs sources without
manual adjustment."
  (directory-file-name directory))

;;; Session API

(defun opencode-sdk-session-list (directory limit roots callback)
  "Asynchronously fetch sessions from GET /session.

DIRECTORY is a string path to filter sessions by.
LIMIT is the maximum number of sessions to return.
ROOTS is a boolean indicating whether to include root sessions.
CALLBACK is called with (SESSIONS ERROR) where SESSIONS is a list of
session alists on success and ERROR is a string on failure."
  (let ((params (list (list "directory" (opencode-sdk--normalize-directory directory))
                      (list "limit" (number-to-string limit))
                      (list "roots" (if roots "true" "false")))))
    (opencode-sdk--request
     'get "/session" params nil
     (lambda (result error)
       (if error
           (funcall callback nil error)
         (funcall callback (or (and (arrayp result) (append result nil))
                               (and (listp result) result)
                               '())
                  nil))))))

(provide 'opencode-sdk)
;;; opencode-sdk.el ends here
