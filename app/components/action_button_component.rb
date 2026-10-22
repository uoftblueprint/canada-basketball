class ActionButtonComponent < ViewComponent::Base
  COLOR_CLASSES = {
    neutral: "btn-neutral",
    primary: "btn-primary",
    secondary: "btn-secondary",
    accent: "btn-accent",
    info: "btn-info",
    success: "btn-success",
    warning: "btn-warning",
    error: "btn-error"
  }.freeze

  private_constant :COLOR_CLASSES

  def initialize(to:, icon:, color: :primary, method: :get, confirm: nil, turbo_stream: false, size: :small)
    super()

    raise ArgumentError, "Invalid color" unless COLORS.include?(color)

    @to = to
    @icon = icon
    @color = color
    @method = method
    @confirm = confirm
    @turbo_stream = turbo_stream
    @size = size
  end

  def form_data
    { turbo_confirm: @confirm.presence, turbo_stream: (@turbo_stream ? true : nil) }.compact
  end

  def link_data
    { turbo_stream: (@turbo_stream ? true : nil) }.compact
  end

  private

  def small? = @size == :small
  def medium? = @size == :medium
  def large? = @size == :large

  def render_method(&)
    if @method == :get
      link_to(@to, data: link_data, class: css_classes, &)
    else
      button_to(@to, method: @method, form: { data: form_data }, class: css_classes, &)
    end
  end

  def css_classes
    class_names(
      "btn active:btn-active",
      COLOR_CLASSES[@color],
      small? && "btn-xs btn-square btn-soft",
      medium? && "btn-sm px-3 py-2 gap-2 font-semibold",
      large? && "btn-md px-4 py-3 gap-2 font-semibold shadow-sm"
    )
  end
end
