ActionController::Routing::Routes.draw do |map|

  map.resources :children

  #this must go before the sponsorships route
  map.resource :amounts, :name_prefix => 'mybb_sponsorships_',
                         :path_prefix => 'mybb/sponsorships',
                         :controller  => 'mybb/sponsorship_amounts'

  map.namespace :mybb do |mybb|
    mybb.resources :sponsorships
  end

  map.static_page ':page',
    :controller => 'static_page',
    :action => 'show',
    :page => Regexp.new(%w[about contact sponsorship child_profile child_profile_gallery child_profile_videos schools_index school_profile school_profile_gallery school_profile_videos school_profile_contact].join('|'))

  map.root :controller => 'home', :action => 'index' # a replacement for public/index.html, with unique layout

end
