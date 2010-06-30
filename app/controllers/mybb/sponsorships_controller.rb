class Mybb::SponsorshipsController < InheritedResources::Base

  #actions :index, :show, :new, :edit, :create, :update, :destroy
  actions :new, :create, :edit
  respond_to :html, :js, :xml, :json

  protected

    def collection
      paginate_options ||= {}
      paginate_options[:page] ||= (params[:page] || 1)
      paginate_options[:per_page] ||= (params[:per_page] || 20)
      @sponsorships ||= end_of_association_chain.paginate(paginate_options)
    end

end