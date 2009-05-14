class RewriteContentDisposition
  def initialize app, opts
    @app = app
    @map = opts
  end
  def call env
    res = @app.call(env)
    ext = env["PATH_INFO"].split(".")[-1]
    res[1]["Content-Disposition"] = @map[ext] if @map.has_key?(ext)
    res
  end
end
