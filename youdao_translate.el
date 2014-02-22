;; 
;; (global-set-key "\C-ct" 'youdao-translate)

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
