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
(defun c-mode-tab-func ()
  (interactive)
  (c-indent-line)
  (semantic-ia-complete-symbol (point)))

(defun my-c-mode-hook ()
  (c-set-style "k&r")
  (require 'semantic-gcc)
  (semantic-add-system-include "/usr/include/Gtk-2.0")
  (add-to-list 'semantic-lex-c-preprocessor-symbol-file "/usr/include/stdlib.h")
  (local-set-key [tab] 'c-mode-tab-func)
  )
(add-hook 'c-mode-hook 'my-c-mode-hook)

;;tuning cedet
(load-file "/usr/share/emacs/site-lisp/cedet/common/cedet.el")
(require 'semantic-ia)
(semantic-load-enable-excessive-code-helpers)





		      
				  
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(ecb-auto-activate nil)
 '(ecb-tip-of-the-day nil))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )
