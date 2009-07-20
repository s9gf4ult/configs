;;; init.el -
;; Copyright (C) 2009  

;; Author: segfault <razor@localhost>
;; Keywords: 
(menu-bar-mode 0)
(tool-bar-mode 0)
(global-hl-line-mode t)
(set-face-background 'hl-line "#404040")
;;for autoindention
;;for double braket showing
(show-paren-mode 1)
;;fast gotoline
(global-set-key (kbd "C-M-g") 'goto-line)
;;charset
(setq message-default-charset 'utf-8)

;;tuning makefile-mode
(defun my-makefile-mode-hook ()
  (local-set-key [enter] 'newline-and-indent)
  )
(add-hook 'makefile-mode-hook 'my-makefile-mode-hook)

;;tuning emacs-lisp-mode
(defun my-emacs-lisp-mode-hook ()
  (local-set-key [enter] 'reindent-then-newline-and-indent)
  )
(add-hook 'emacs-lisp-mode-hook 'my-emacs-lisp-mode-hook)






;; tuning c-mode
(defun my-c-mode-hook ()
  (c-set-style "k&r")
  (global-set-key (kbd "<RET>") 'reindent-then-newline-and-indent)
  (require 'semantic-gcc)
  (semantic-add-system-include "/usr/include/Gtk-2.0")
  (add-to-list 'semantic-lex-c-preprocessor-symbol-file "/usr/include/stdlib.h")
  ;;фунция для таба
  (defun c-mode-tab-func ()
    (interactive)
    (c-indent-line)
    (semantic-ia-complete-symbol (point)))
  (local-set-key [tab] 'c-mode-tab-func)
  (defun c-mode-f5-func ()
    (interactive)
    (compile "make -k all")
    )
  (local-set-key [f5] 'c-mode-f5-func)
  (defun c-mode-f6-func ()
    (interactive)
    (compile "make -k debug")
    )
  (local-set-key [f6] 'c-mode-f6-func)
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
