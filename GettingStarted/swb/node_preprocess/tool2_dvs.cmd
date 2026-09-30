#seth VAR2 @node@
#set square @<param1*param1>@

#set result2 -1

(define dummy "
  @node@
  @previous@
  @experiment@
  @experiments@
  @tool_label@
  @pwd@
  @tdrboundary@
  @tdr@
  ;; input output files
  @tdrboundary/i@
  @tdrboundary/o@
  ")

(define xvar (* 10 @result1@))
(sde:ft_scalar "result2" xvar)  