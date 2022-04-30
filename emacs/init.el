(package-initialize)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;; Monokai
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'monokai t)

;; Question with y/n instead of yes/no
(fset 'yes-or-no-p 'y-or-n-p)

(global-linum-mode t)
(setq linum-format "%d ")
(setq column-number-mode t)

;; Soft tab
(setq indent-tabs-mode nil)
(setq tab-always-indent nil)
(setq tab-width 2)
