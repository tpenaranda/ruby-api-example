class ApiSupport
  use Rack::Static,
    urls: %w(/images /css),
    root: 'application/assets',
    header_rules: [
      [:all, {
        'Cache-Control' => 'public, max-age=2592000, no-transform',
        'Connection' => 'keep-alive',
        'Age' => '25637',
        'Strict-Transport-Security' => 'max-age=31536000'
      }]
    ]
end
