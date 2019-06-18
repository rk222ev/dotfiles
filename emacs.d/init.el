(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  )

(package-initialize)

;;; Notes
;; Do I need hippieexpand?
;;

(eval-when-compile
  ;; Following line is not needed if use-package.el is in ~/.emacs.d
  (add-to-list 'load-path "<path where use-package is installed>")
  (require 'use-package))

;;
;; Packages
;;
(use-package ace-window
  :ensure t
  :config
  (global-set-key (kbd "C-x o") 'ace-window))

(use-package better-defaults
  :ensure t)

(use-package clj-refactor
  :ensure t
  :config
  (define-key input-decode-map [?\C-m] [C-m]) ;; Do not treat C-m as RET
  (add-hook 'clojure-mode-hook (lambda ()
                                 (clj-refactor-mode 1)
                                 (cljr-add-keybindings-with-prefix "C-c C-m"))))

(use-package clojure-mode
  :ensure t
  :pin melpa
  :config
  (add-to-list 'auto-mode-alist '("\\.edn$" . clojure-mode))
  (add-to-list 'auto-mode-alist '("\\.boot$" . clojure-mode))
  (add-hook 'clojure-mode-hook 'enable-paredit-mode))

(use-package cider
  :ensure t
  :config
  (setq cider-repl-pop-to-buffer-on-connect t)
  ;; (add-to-list 'auto-mode-alist '("\\.edn$" . clojure-mode))
  ;; (add-to-list 'auto-mode-alist '("\\.boot$" . clojure-mode))
  ;; (add-to-list 'auto-mode-alist '("\\.cljs.*$" . clojure-mode))
  ;; (add-hook 'clojure-mode-hook 'enable-paredit-mode)
  )

(use-package clojure-mode-extra-font-locking
  :ensure t)

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (define-key evil-normal-state-map  "\M-." 'nil)
  ;; (eval-after-load "evil-maps"
  ;; '(progn
  ;;    ))
  )

(use-package evil-collection
  :ensure t
  :after evil
  :custom
  (evil-collection-outline-bind-tab-p nil)
  :config
  (evil-collection-init))

(use-package evil-magit
  :ensure t
  :after (magit evil))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package ido-completing-read+
  :ensure t
  :config
  (ido-ubiquitous-mode 1))

(use-package ido-vertical-mode
  :ensure t
  :config
  (ido-vertical-mode 1)
  (setq ido-vertical-define-keys 'C-n-and-C-p-only))

(use-package magit
  :ensure t)

(use-package ob-shell
  :after evil)

(defun org-custom-keys ()
  "Use n/p instead of arrow keys for moving items since they are unbinded."
  (local-set-key (kbd "M-n") #'org-metadown)
  (local-set-key (kbd "M-p") #'org-metaup))

(use-package org
  :ensure org-plus-contrib
  :config
  (setq org-duration-format (quote h:mm))
  (with-eval-after-load 'evil-maps
    (define-key org-mode-map "\M-j" #'org-metadown)
    (define-key org-mode-map "\M-k" #'org-metaup)
    (define-key org-mode-map "\M-h" #'org-metaleft)
    (define-key org-mode-map "\M-l" #'org-metaright)
    (define-key global-map "\C-ca" 'org-agenda)
    (define-key global-map "\C-cc" 'org-capture))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (shell . t)
     (sql . t)
     (sqlite . t)
     (ruby . t)
     (scheme . t)
     (java . t)
     (clojure . t)
     (python . t)))
  (add-hook 'org-mode-hook (lambda ()
                             (auto-fill-mode 1)
                             (setq org-src-fontify-natively t)
                             (org-custom-keys)))
  (setq org-agenda-files (list "~/Documents/work.org" "~/Documents/home.org"))
  (setq org-capture-templates
        '(("t" "Personal Task" entry (file "~/Documents/home.org")
           "* TODO %?" :emptylines 1)
          ("A" "Appointment -  Home" entry (file+headline "~/Documents/home.org" "Appointments")
           "** %?\n   %T" :empty-lines 1)
          ("p" "Punch In" entry (file+headline "~/Documents/work.org" "log")
           "* %u \n %?" :clock-in t :clock-keep t)
          ("w" "Work-related Task" entry (file "~/Documents/work.org")
           "* TODO %?" :emptylines 1)
          ("a" "Appointment -  work" entry (file+headline "~/Documents/work.org" "Appointments")
           "** %?\n   %T" :empty-lines 1)
          ("b" "Bookmark" entry (file+headline "~/Documents/home.org" "Bookmarks")
           "* %?\n :PROPERTIES:\n:CREATED: %U\n:END:\n\n" :empty-lines 1))))

(use-package evil-org
  :ensure t
  :after org
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'evil-org-mode-hook
            (lambda ()
              (evil-org-set-key-theme)))
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package paredit
  :ensure t)

(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (setq projectile-indexing-method 'hybrid) ;; Use .projectile files
  ;(projectile-global-mode)
  )

(use-package uniquify
  :config
  (setq uniquify-buffer-name-style 'forward))

(use-package smex
  :ensure t
  :config
  (setq smex-save-file (concat user-emacs-directory ".smex-items"))
  (smex-initialize)
  (global-set-key (kbd "M-x") 'smex))

(use-package slime
  :ensure t
  :config
  (setq inferior-lisp-program "/usr/bin/sbcl")
  (slime-setup '(slime-asdf
                 slime-autodoc
                 slime-editing-commands
                 slime-fancy-inspector
                 slime-fontifying-fu
                 slime-fuzzy
                 slime-indentation
                 slime-mdot-fu
                 slime-package-fu
                 slime-references
                 slime-repl
                 slime-sbcl-exts
                 slime-scratch
                 slime-xref-browser))
  (slime-autodoc-mode)
  (setq slime-complete-symbol*-fancy t)
  (setq slime-complete-symbol-function
        'slime-fuzzy-complete-symbol))

;;
;; Lib
;;
(defun load-directory (dir)
  (let ((load-it (lambda (f)
                   (load-file (concat (file-name-as-directory dir) f)))))
    (mapc load-it (directory-files dir nil "\\.el$"))))
(load-directory "~/.emacs.d/lib/")

;;
;; Backups
;;
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups"))))
(setq auto-save-default nil)

;;
;; Locale
;;
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;;
;; Calendar
;;
(setq calendar-week-start-day 1)

; Add week numbers
(copy-face font-lock-constant-face 'calendar-iso-week-face)
(set-face-attribute 'calendar-iso-week-face nil :height 0.7)
(setq calendar-intermonth-text
      '(propertize
        (format "%2d"
                (car
                 (calendar-iso-from-absolute
                  (calendar-absolute-from-gregorian (list month day year)))))
        'font-lock-face 'calendar-iso-week-face))

;;
;; Lisp
;;
(autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
(add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
(add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
(add-hook 'ielm-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-mode-hook             #'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
(add-hook 'scheme-mode-hook           #'enable-paredit-mode)

;eldoc-mode shows documentation in the minibuffer when writing code http://www.emacswiki.org/emacs/ElDoc

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)

;;
;; MISC
;;
(blink-cursor-mode 0)
(setq ring-bell-function 'ignore)
(setq inhibit-splash-screen t)
;(set-face-attribute 'default nil :height 110)
(fset 'yes-or-no-p 'y-or-n-p)

(setq vc-follow-symlinks t)

(setq create-lockfiles nil)

(pdf-tools-install)

(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

(setq ag-reuse-window 't)

(push '(" fn ") prettify-symbols-alist)
(global-prettify-symbols-mode +1)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(setq cider-offer-to-open-cljs-app-in-browser nil)

(setq dired-listing-switches "-alh")

;; Focus buffer
(defvar window-split-saved-config nil)
(defun window-split-toggle-one-window ()
  "Make the current window fill the frame.
  If there is only one window try reverting to the most recently saved
  window configuration."
  (interactive)
  (if (and window-split-saved-config (not (window-parent)))
      (set-window-configuration window-split-saved-config)
    (setq window-split-saved-config (current-window-configuration))
    (delete-other-windows)))

 (global-set-key (kbd "C-x 1") 'window-split-toggle-one-window)

;Nov.el
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
(setq nov-text-width 80)

;; Save clipboard strings into kill ring before replacing them. When one selects something in another program to paste it into Emacs, but kills something in Emacs before actually pasting it, this selection is gone unless this variable is non-nil
(setq save-interprogram-paste-before-kill t)

;; Ido
(ido-mode t)
(setq ido-enable-flex-matching t)
(setq ido-use-filename-at-point nil)
(setq ido-auto-merge-work-directories-length -1)
;; (setq ido-use-virtual-buffers t)

;; Keys
(defun toggle-comment-on-line ()
  "comment or uncomment current line"
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))
(global-set-key (kbd "C-;") 'toggle-comment-on-line)

(defun rk-init.el ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))

;; TODO fix
;; (add-hook 'clojure-mode-hook #'inf-clojure-minor-mode)
;; (setq inf-clojure-generic-cmd "planck -d")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#2d3743" "#ff4242" "#74af68" "#dbdb95" "#34cae2" "#008b8b" "#00ede1" "#e1e1e0"])
 '(custom-safe-themes
   (quote
    ("d97baf5a34c87b05508739505cad03438cde8efa2a0d350c7773f2a8bc26a50d" "4780d7ce6e5491e2c1190082f7fe0f812707fc77455616ab6f8b38e796cbffa9" "cc0dbb53a10215b696d391a90de635ba1699072745bf653b53774706999208e3" "3e335d794ed3030fefd0dbd7ff2d3555e29481fe4bbb0106ea11c660d6001767" default)))
 '(elfeed-feeds
   (quote
    ("https://nullprogram.com/feed/" "https://planet.emacslife.com/atom.xml" "http://fetchrss.com/rss/5ce3c0e18a93f86d578b45675ce3c0a78a93f812558b4567.xml" "http://endlessparentheses.com/atom.xml" "http://insideclojure.org/feed.xml")))
 '(evil-collection-outline-bind-tab-p nil)
 '(org-agenda-files (quote ("~/Documents/home.org" "~/Documents/work.org")))
 '(package-selected-packages
   (quote
    (telephone-line project-explorer basic-theme minimal-theme evil-org-agenda org-evil evil-org org-static-blog cargo rust-mode go-mode buttercup pass clj-refactor elfeed ag request pdf-tools ace-window smex clojure-mode-extra-font-locking uniquify cider slime projectile nov org-plus-contrib evil-magit ido-completing-read+ ido-vertical-mode magit better-defaults evil-surround evil-collection 0blayout intero haskell-mode paredit use-package evil)))
 '(safe-local-variable-values
   (quote
    ((org-static-blog-publish-title . "rpkn.se")
     (cider-default-cljs-repl . "shadow")
     (cider-preferred-build-tool 1)
     (cider-preferred-build-tool quote shadow-cljs)
     (cider-default-cljs-repl . "Shadow")
     (cider-preferred-build-tool shadow-cljs)
     (cider-preferred-build-tool
      (quote shadow-cljs))
     (cider-preferred-build-tool "shadow-cljs")
     (cider-default-cljs-repl "Shadow")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
