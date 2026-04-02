;;; opencode.el --- Use OpenCode from emacs -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Diogo Doreto
;;
;; Author: Diogo Doreto <diogo@doreto.com.br>
;; Maintainer: Diogo Doreto <diogo@doreto.com.br>
;; Created: March 31, 2026
;; Modified: March 31, 2026
;; Version: 0.0.1
;; Keywords: tools convenience
;; Homepage: https://github.com/local_diogodoreto/opencode
;; Package-Requires: ((emacs "28.1") (opencode-sdk "0.0.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Use OpenCode from emacs
;;
;;; Code:

(require 'transient)
(require 'project)
(require 'opencode-sdk)

;;; Project Root Resolution

(defun opencode--project-root ()
  "Return the current project root directory.
Uses `project-current' to detect the project.  Falls back to
`default-directory' when no project is found."
  (if-let ((proj (project-current)))
      (project-root proj)
    default-directory))

;;; Transient Menu State

(defvar opencode--menu-sessions nil
  "List of session alists populated by `opencode--show-menu' before display.
Each alist has at least `id', `directory', and `title' entries.
Read by the Sessions group `:setup-children' function at display time.")

(defvar opencode--menu-directory nil
  "Project root directory string populated by `opencode--show-menu' before display.
Read by the Actions group `:setup-children' function to pass to
`opencode-sdk-session-create'.")

;;; URL Helpers

(defun opencode--session-url (directory session-id)
  "Return the browser URL for SESSION-ID under DIRECTORY.
The first path segment is the base64 encoding of DIRECTORY
(without trailing newline), which is how OpenCode identifies
the project in its web UI."
  (let ((encoded-dir (base64-encode-string directory t)))
    (concat opencode-sdk-base-url "/" encoded-dir "/session/" session-id)))

;;; Transient Menu Builder

(defun opencode--build-session-suffix (key session)
  "Build a transient suffix spec for SESSION bound to KEY.
KEY is a string such as \"1\".  SESSION is an alist with at least
`id', `directory', and `title' entries.  The suffix action opens
the session URL in the browser.

Signals an error if SESSION is missing `id' or `directory'.

Returns a list spec suitable for `transient-parse-suffix'."
  (let ((session-id  (alist-get 'id session))
        (directory   (alist-get 'directory session)))
    (unless (and session-id directory)
      (error "OpenCode: malformed session alist: %S" session))
    (let* ((title (or (alist-get 'title session) (concat "Session " key)))
           (url (opencode--session-url directory session-id)))
      (list key title
            (lambda ()
              (interactive)
              (browse-url url))))))

(transient-define-prefix opencode--menu-prefix ()
  "OpenCode session menu (populated dynamically)."
  ["Sessions"
   :class transient-column
   :hide (lambda () (null opencode--menu-sessions))
   :setup-children
   (lambda (_children)
     (transient-parse-suffixes
      'opencode--menu-prefix
      (cl-loop for session in opencode--menu-sessions
               for key in '("1" "2" "3" "4" "5")
               collect (opencode--build-session-suffix key session))))]
  ["Actions"
   :setup-children
   (lambda (_children)
     (transient-parse-suffixes
      'opencode--menu-prefix
      (let ((directory opencode--menu-directory))
        (list
         (list "n" "New session"
               (lambda ()
                 (interactive)
                 (opencode-sdk-session-create
                  directory
                  (lambda (session error)
                    (if error
                        (message "OpenCode: failed to create session: %s" error)
                      (browse-url
                       (opencode--session-url directory
                                              (alist-get 'id session))))))))))))])

(defun opencode--show-menu (sessions directory)
  "Display the OpenCode transient menu with SESSIONS and DIRECTORY.
Sets `opencode--menu-sessions' and `opencode--menu-directory' so that
the `:setup-children' functions can read them at display time, then
invokes the transient prefix."
  (setq opencode--menu-sessions sessions)
  (setq opencode--menu-directory directory)
  (opencode--menu-prefix))

;;; Main Command

;;;###autoload
(defun opencode-menu ()
  "Open the OpenCode session menu for the current project.
Resolves the project root, fetches up to 5 recent sessions
asynchronously, then displays a `transient' menu.  Sessions are
bound to keys 1–5; key `n' creates a new session.  Selecting an
entry opens the session in the browser."
  (interactive)
  (let ((directory (opencode--project-root)))
    (message "Fetching OpenCode sessions...")
    (opencode-sdk-session-list
     directory 5 t
     (lambda (sessions error)
       (if error
           (message "OpenCode: %s" error)
         (opencode--show-menu sessions directory))))))

(provide 'opencode)
;;; opencode.el ends here
