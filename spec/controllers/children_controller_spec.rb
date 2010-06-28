require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../factories/child'

describe ChildrenController do
  integrate_views

  before(:each) do
    @child = Factory.build(:child)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  

  it "show action should render show template" do
    get :show, :id => Child.first
    response.should render_template(:show)
  end
  

  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  

  it "create action should render new template when model is invalid" do
    Child.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    Child.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(resource_url(assigns[:resource]))
  end


  it "edit action should render edit template" do
    get :edit, :id => Child.first
    response.should render_template(:edit)
  end
  
  
  it "update action should render edit template when model is invalid" do
    Child.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Child.first
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    Child.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Child.first
    response.should redirect_to(resource_url(assigns[:resource]))
  end
  

  it "destroy action should destroy model and redirect to index action" do
    resource = Child.first
    delete :destroy, :id => resource
    response.should redirect_to(resources_url)
    Child.exists?(resource.id).should be_false
  end
  

end