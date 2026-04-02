;;; opencode.el --- Use OpenCode from emacs -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2026 Diogo Doreto
;;
;; Author: Diogo Doreto <diogo@doreto.com.br>
;; Maintainer: Diogo Doreto <diogo@doreto.com.br>
;; Created: March 31, 2026
;; Modified: March 31, 2026
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex text tools unix vc wp
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
Each alist has at least `id', `projectId', and `title' entries.
Read by the Sessions group `:setup-children' function at display time.")

(defvar opencode--menu-directory nil
  "Project root directory string populated by `opencode--show-menu' before display.
Used by `opencode--new-session' (set via `opencode--build-new-session-suffix')
to know which directory to create new sessions in.")

;;; Transient Menu Builder

(defun opencode--build-session-suffix (key session)
  "Build a transient suffix spec for SESSION bound to KEY.
KEY is a string such as \"1\".  SESSION is an alist with at least
`id', `projectId', and `title' entries.  The suffix action opens
the session URL in the browser.

Returns a list spec suitable for `transient-parse-suffix'."
  (let* ((session-id (alist-get 'id session))
         (project-id (alist-get 'projectId session))
         (title (or (alist-get 'title session) (concat "Session " key)))
         (url (concat opencode-sdk-base-url "/" project-id "/session/" session-id))
         (cmd-sym (intern (format "opencode--session-%s" key))))
    (defalias cmd-sym
      (lambda ()
        (interactive)
        (browse-url url))
      (format "Open OpenCode session in browser (%s)" title))
    (put cmd-sym 'interactive-only t)
    (list key title cmd-sym)))

(defun opencode--build-new-session-suffix (directory)
  "Build a transient suffix spec for creating a new session in DIRECTORY.
Bound to key `n' and labelled \"New session\".

Returns a list spec suitable for `transient-parse-suffix'."
  (defalias 'opencode--new-session
    (lambda ()
      (interactive)
      (opencode-sdk-session-create
       directory
       (lambda (session error)
         (if error
             (message "OpenCode: failed to create session: %s" error)
           (let* ((session-id (alist-get 'id session))
                  (project-id (alist-get 'projectId session))
                  (url (concat opencode-sdk-base-url
                               "/" project-id
                               "/session/" session-id)))
             (browse-url url))))))
    "Create a new OpenCode session and open it in the browser.")
  (put 'opencode--new-session 'interactive-only t)
  (list "n" "New session" 'opencode--new-session))

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
   ("n" "New session" opencode--new-session)])

(defun opencode--show-menu (sessions directory)
  "Display the OpenCode transient menu with SESSIONS and DIRECTORY.
Sets `opencode--menu-sessions' and `opencode--menu-directory' so that
the Sessions group `:setup-children' function can read them at display
time.  Redefines `opencode--new-session' for DIRECTORY, then invokes
the transient prefix."
  (setq opencode--menu-sessions sessions)
  (setq opencode--menu-directory directory)
  (opencode--build-new-session-suffix directory)
  (transient-setup 'opencode--menu-prefix))

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
