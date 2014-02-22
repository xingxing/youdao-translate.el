;;; youdao-translate.el --- Emacs interface to Youdao Translate

;; Copyright (C) 2014 Wade Xing <iamxingxing@gmail.com>

;; Author: Wade Xing 
;; Version: 0.1
;; Keywords: convenience


;; This file is NOT part of GNU Emacs.

;; 
;; This is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;; (global-set-key "\C-ct" 'youdao-translate)

(require 'url)
(require 'json)

(defvar youdao-translate-url
  "http://fanyi.youdao.com/openapi.do?keyfrom=wadexing&key=89413557&type=data&doctype=json&version=1.1&q=")

(defun youdao-translate-make-query-url (text)
  "构造查询地址"
  (concat youdao-translate-url text))

(defun youdao-translate-pick-up-words ()
  "可以选择用region和取当前词"
  (interactive "P")
  (if (use-region-p)
      (buffer-substring-no-properties (region-beginning) (region-end))
    (or (current-word t)
	nil)))

(defun youdao-translate-get-result (words)
  "GET 有道API"
  (plist-get
   (plist-get
    (let ((json-object-type 'plist))
      (json-read-from-string
       (with-current-buffer (url-retrieve-synchronously (youdao-translate-make-query-url words))
	 (set-buffer-multibyte t)
	 (goto-char (point-min))
	 (re-search-forward (format "\n\n"))
	 (delete-region (point-min) (point))
	 (prog1 (buffer-string) (kill-buffer))))) :basic) :explains))

(defun youdao-translate-insert (results)
  "打印翻译结果"
  (let ((i 0))
    (while (< i (length results))
      (insert (format "%d. %s\n" (1+ i) (elt results i)))
      (setq i (1+ i)))))


(defun youdao-translate (&optional arg)
  (interactive "P")
  (let ((words (youdao-translate-pick-up-words)))
    (with-output-to-temp-buffer "~Youdao Translate~"
      (set-buffer "~Youdao Translate~")
      (if words
	  (youdao-translate-insert (youdao-translate-get-result words))
	(insert "无词可查！")))))
