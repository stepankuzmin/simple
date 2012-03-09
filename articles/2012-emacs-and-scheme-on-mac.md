Date: 2012-02-21
Title: Emacs and Scheme on Mac OS X
Slug: emacs-scheme
Tags: emacs, scheme, mac
Category: howto
Abstract: Simple HOWTO for setting up Emacs Scheme environment on Mac OS X

First of all, we need to [download MIT Scheme](http://www.gnu.org/software/mit-scheme/) from official website and install it as usual Mac application.

Second, [download Emacs for Mac OS X](http://emacsformacosx.com/) and install it too.

After that, you should set up Scheme support in Emacs. Open `~/.emacs` and paste following code there:

    (setq scheme-program-name
      "/Applications/MIT: Scheme/Contents/Resources/mit-scheme")
    (require 'xscheme)

Here we go. After running Emacs, you could write some Scheme code, for example:

    (define (fact x)
      (if (< x 3)
          x
          (* (fact (- x 1)) x)))

Start Scheme buffer like `M-x run-scheme` and execute your code `M-o`. That's all!