require_dependency 'wizard/step'
require_dependency 'wizard/field'

class Wizard
  attr_reader :start
  attr_reader :steps

  def initialize
    @steps = []
  end

  def create_step(step_name)
    Step.new(step_name)
  end

  def append_step(step)
    step = create_step(step) if step.is_a?(String)

    yield step if block_given?

    last_step = @steps.last

    @steps << step

    # If it's the first step
    if @steps.size == 1
      @start = step
      step.index = 0
    elsif last_step.present?
      last_step.next = step
      step.previous = last_step
      step.index = last_step.index + 1
    end
  end

  def self.build
    wizard = Wizard.new

    wizard.append_step('locale') do |step|
      languages = step.add_field(id: 'default_locale',
                                 type: 'dropdown',
                                 required: true,
                                 value: SiteSetting.default_locale)

      LocaleSiteSetting.values.each do |locale|
        languages.add_choice(locale[:value], label: locale[:name])
      end
    end

    wizard.append_step('forum-title') do |step|
      step.add_field(id: 'title', type: 'text', required: true, value: SiteSetting.title)
      step.add_field(id: 'site_description', type: 'text', required: true, value: SiteSetting.site_description)
    end

    wizard.append_step('contact') do |step|
      step.add_field(id: 'contact_email', type: 'text', required: true, value: SiteSetting.contact_email)
      step.add_field(id: 'contact_url', type: 'text', value: SiteSetting.contact_url)
      step.add_field(id: 'site_contact_username', type: 'text', value: SiteSetting.site_contact_username)
    end

    wizard.append_step('colors') do |step|
      themes = step.add_field(id: 'color_scheme', type: 'dropdown', required: true)
      ColorScheme.themes.each {|t| themes.add_choice(t[:id], data: t) }
      step.add_field(id: 'scheme_preview', type: 'component')
    end

    wizard.append_step('finished')

    wizard
  end
end
