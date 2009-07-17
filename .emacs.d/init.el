;;; init.el -
;; Copyright (C) 2009  

;; Author: segfault <razor@localhost>
;; Keywords: 
(menu-bar-mode 0)
(tool-bar-mode 0)
(global-hl-line-mode t)
(set-face-background 'hl-line "#404040")
;;for autoindention
(global-set-key (kbd "<RET>") 'reindent-then-newline-and-indent)
;;for double braket showing
(show-paren-mode 1)
;;fast gotoline
(global-set-key (kbd "C-M-g") 'goto-line)
;;charset
(setq message-default-charset 'utf-8)
;; tuning c-mode
(defun my-c-mode-hook ()
  "docs"
  (interactive)
  (c-set-style "k&r"))
(add-hook 'c-mode-hook 'my-c-mode-hook)

;;tuning cedet
(load-file "/usr/share/emacs/site-lisp/cedet/common/cedet.el")
(semantic-load-enable-excessive-code-helpers)
(require 'semantic-ia)
(require 'semantic-gcc)

		      
				  