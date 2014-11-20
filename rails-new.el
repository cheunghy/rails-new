;;; rails-new.el --- Handy emacs command for generating rails application.

;; Copyright (C) 2014 Zhang Kai Yu

;; Author: Zhang Kai Yu <yeannylam@gmail.com>
;; Version: 0.1.0
;; Keywords: rails, ruby
;; URL: https://github.com/cheunghy/rails-new

;;; Commentary:

;; This package provides a handy command:
;; M-x rails-new
;; for generating rails application.

(defvar rn/last-rails-new-command nil
  "This variable hold last user rails new command.")

(defvar rn/last-rails-dir nil
  "This variable hold the dir location of last user created rails app.")

;; TODO: bug exist.
(defvar rn/file-re
  "^\\s-+\\(?:create\\|exist\\|identical\\|conflict\\|new\\|skip\\)\\s-+\\(.+\\)$")

;;;###autoload
(defun rails-new-again ()
  "Retry last rails new command."
  (interactive)
  (rn/compile))
;;;###autoload
(defun rails-new (dir &optional ruby template
                      skip-gemfile skip-bundle skip-git
                      skip-keeps skip-active-record skip-action-view
                      skip-sprockets skip-spring database
                      js-library skip-js skip-test-unit
                      )
  "Create new rails app."
  (interactive (list (read-directory-name "Directory: ") ;; parameter 1
                     (if (y-or-n-p "Use default ruby executable?")
                         nil
                       (read-file-name "Ruby: ")) ;; parameter 2
                     (if (y-or-n-p "Use template file?")
                         (read-file-name "Template file: ")
                       nil) ;; parameter 3
                     (y-or-n-p "Skip Gemfile?") ;; parameter 4
                     (y-or-n-p "Skip bundle?") ;; parameter 5
                     (y-or-n-p "Skip git?") ;; parameter 6
                     (y-or-n-p "Skip keeps?") ;; parameter 7
                     (y-or-n-p "Skip active record?") ;; parameter 8
                     (y-or-n-p "Skip action view?") ;; parameter 9
                     (y-or-n-p "Skip sprockets?") ;; parameter 10
                     (y-or-n-p "Skip spring?") ;; parameter 11
                     (if (y-or-n-p "Use default sqlite3 database?")
                         nil
                       (completing-read "Database name: "
                                        (list
                                         "mysql" "oracle" "postgresql"
                                         "frontbase" "ibm_db"
                                         "sqlserver" "jdbcmysql" "jdbcsqlite3"
                                         "jdbcpostgresql""jdbc")
                                        nil nil nil nil
                                        "sqlite3")) ;; param 12
                     (if (y-or-n-p "Use default js library(jQuery)?")
                         nil
                       (completing-read "js library: "
                                        (list "prototype")
                                        nil nil nil nil
                                        "jquery")
                       ) ;; parameter 13
                     (y-or-n-p "Skip javascript?") ;; parameter 14
                     (y-or-n-p "Skip test unit?") ;; parameter 15
                     ))

  (let ((rails-new-command
         (with-temp-buffer
           (insert "rails new " dir " ")
           (if ruby (insert "--ruby=" ruby " "))
           (if template (insert "--template=" template " "))
           (if skip-gemfile (insert "--skip-gemfile "))
           (if skip-bundle (insert "--skip-bundle "))
           (if skip-git (insert "--skip-git "))
           (if skip-keeps (insert "--skip-keeps "))
           (if skip-active-record (insert "--skip-active-record "))
           (if skip-action-view (insert "--skip-action-view "))
           (if skip-sprockets (insert "--skip-sprockets "))
           (if skip-spring (insert "--skip-spring "))
           (if database (insert "--database=" database " "))
           (if js-library (insert "--javascript=" js-library " "))
           (if skip-js (insert "--skip-javascript "))
           (if skip-test-unit (insert "--skip-test-unit"))
           (buffer-string)
           )))
    (setq rn/last-rails-dir dir)
    (setq rn/last-rails-new-command rails-new-command)
    (rn/compile)))

(defun rn/compile ()
  (compile rn/last-rails-new-command 'rails-new-mode))

(define-derived-mode rails-new-mode compilation-mode
  "Happy coding!"
  "Mode for rails new command."
  (add-hook 'compilation-filter-hook 'rn/apply-ansi-color-and-generate-link
            nil t)
  )

(defun rn/apply-ansi-color-and-generate-link ()
  (read-only-mode)
  (ansi-color-apply-on-region compilation-filter-start (point))
  (message "Called. ! !")
  (rn/generate-buffer-links (current-buffer))
  (read-only-mode))


(defun rn/jump-to-file (button)
  (let ((the-file (rn/full-file-name (button-label button))))
    (if (file-directory-p the-file)
        (dired the-file)
      (find-file the-file))))

(defun rn/file-exists-p (file)
  (let ((file-name (format "%s/%s" rn/last-rails-dir file)))
    (if (file-exists-p file-name) file-name nil)))

(defalias 'rn/full-file-name 'rn/file-exists-p)

(defun rn/generate-buffer-links (buffer &optional exit-code)
  (with-current-buffer buffer
    ;; TODO: Remove button if the file not exist anymore.
    ;; This line doesn't work.
    ;;(remove-text-properties 0 (buffer-end) '(mouse-face nil))
    (goto-char 0)
    (while (re-search-forward rn/file-re (max-char) t)
      ;; TODO: Bug exists. this won't run.
      (if (rn/file-exists-p
           (buffer-substring-no-properties (match-beginning 1) (match-end 1)))
          (make-button
           (match-beginning 1)
           (match-end 1)
           'action
           'rn/jump-to-file
           'follow-link
           t)))))

(provide 'rails-new)
;;; rails-new.el ends here
