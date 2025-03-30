<!DOCTYPE html>
<html>
  <head>
    <script src="/assets/jquery-3.7.0.min.js"></script>
    <!--
    <link rel="stylesheet" href="/assets/bootstrap.min.css">
    <script src="/assets/bootstrap.min.js"></script>
    -->

  {% include head.html %}

    <body>

    {% include header.html %}

    <div class="page-content">
      <div class="wrap">
      {{ content }}
      </div>
    </div>

    {% include footer.html %}

    <!-- mathjax -->
    <script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
    </body>
</html>