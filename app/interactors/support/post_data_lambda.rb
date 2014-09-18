
# Module containing domain service-level objects, aka DSOs or interactors.
module DSO
  POST_DATA_LAMBDA = lambda do |dso|
    dso.string :author_name, default: '', strip: true
    dso.string :body, default: '', strip: true
    dso.time :created_at, default: nil
    dso.string :image_url, default: '', strip: true
    dso.date :pubdate, default: nil
    dso.string :slug, default: nil, strip: true
    dso.string :title, default: '', strip: true
  end
end
