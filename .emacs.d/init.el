;;; init.el -
;; Copyright (C) 2009  

;; Author: segfault <razor@localhost>
;; Keywords: 
(menu-bar-mode 0)

(tool-bar-mode 0)
(semantic-load-enable-minimum-features)
(semantic-load-enable-all-exuberent-ctags-support)
(semantic-load-enable-code-helpers)
(global-hl-line-mode t)
(set-face-background 'hl-line "#404040")
;;for autoindention
(global-set-key (kbd "<RET>") 'reindent-then-newline-and-indent)
;;for double braket showing
(show-paren-mode 1)
;;fast gotoline
(global-set-key (kbd "C-M-g") 'goto-line)
(setq message-default-charset 'utf-8)