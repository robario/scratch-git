;;; scratch-git.el --- persist the scratch buffer using git

;; Copyright (C) 2014 robario

;; Author: robario <webmaster@robario.com>
;; URL: https://github.com/robario/scratch-git
;; Keywords: scratch, persist
;; Version: 20140930.58

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This persist the scratch buffer using git.

;;; Code:



(defvar scratch-git-directory (locate-user-emacs-file "scratch/"))
(defvar scratch-git-file (expand-file-name "scratch" scratch-git-directory))

;;;###autoload
(defun scratch-git-resume ()
  "resume scratch or initialize"
  (interactive)
  (with-current-buffer (get-buffer-create "*scratch*")
    (erase-buffer)
    (if (file-exists-p scratch-git-file)
        (insert-file-contents scratch-git-file)
      (make-directory scratch-git-directory t)
      (shell-command (format "cd %s && git init && git config --add user.name %s && git config --add user.email %s"
                             scratch-git-directory
                             user-login-name
                             user-mail-address))
      (funcall initial-major-mode)
      (when (and initial-scratch-message (not inhibit-startup-message))
        (insert initial-scratch-message))
      (scratch-git-save))))

;;;###autoload
(defun scratch-git-save ()
  "save scratch"
  (interactive)
  (with-current-buffer (get-buffer "*scratch*")
    (write-region nil nil scratch-git-file)
    (shell-command (format "cd %s && git commit --all --allow-empty-message --message=''" scratch-git-directory))))

;;;###autoload
(add-hook 'after-init-hook 'scratch-git-resume)

;;;###autoload
(add-hook 'after-save-hook
          #'(lambda ()
              (unless (member (get-buffer "*scratch*") (buffer-list))
                (scratch-git-resume))))

;;;###autoload
(add-hook 'kill-buffer-query-functions
          #'(lambda ()
              (if (string= "*scratch*" (buffer-name))
                  (progn (scratch-git-resume) nil)
                t)))

;;;###autoload
(add-hook 'kill-emacs-hook 'scratch-git-save)

(provide 'scratch-git)
;;; scratch-git.el ends here
