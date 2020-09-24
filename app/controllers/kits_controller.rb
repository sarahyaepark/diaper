class KitsController < ApplicationController
  def index
    @kits = current_organization.kits.class_filter(filter_params)
    @selected_item = filter_params[:by_item]
    @include_inactive = params[:include_inactive]
    unless params[:include_inactive]
      @kits = @kits.active
    end
  end

  def new
    load_form_collections
    @kit = current_organization.kits.new
    @kit.line_items.build
  end

  def create
    @kit = current_organization.kits.new(kit_params)
    @kit.organization_id = current_organization.id
    if @kit.save
      flash[:notice] = "Kit created successfully"
      redirect_to kits_path
    else
      flash[:error] = @kit.errors.full_messages.to_sentence
      load_form_collections
      render :new
    end
  end

  private

  def load_form_collections
    @items = current_organization.items.active.alphabetized
  end

  def kit_params
    params.require(:kit).permit(:name, line_items_attributes: [:item_id, :quantity, :_destroy])
  end

  def filter_params
    return {} unless params.key?(:filters)

    params.require(:filters).slice(:by_item, :include_inactive_items)
  end
end
