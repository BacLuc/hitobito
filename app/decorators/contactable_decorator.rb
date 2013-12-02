# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module ContactableDecorator

  def address_name
    content_tag(:strong, to_s)
  end

  def complete_address
    html = ''.html_safe

    prepend_complete_address(html)

    html << safe_join(address.split("\n"), br) << br if address?
    html << zip_code.to_s if zip_code?
    html << ' ' << town if town?

    if !ignored_country?
      html << br if zip_code? || town?
      html << country
    end

    content_tag(:p, html)
  end

  def complete_contact
    address_name +
    complete_address +
    primary_email +
    all_phone_numbers(true) +
    all_social_accounts(true)
  end

  def primary_email
    if email.present?
      content_tag(:p, h.mail_to(email))
    end
  end

  def all_phone_numbers(only_public = true)
    nested_values(phone_numbers, only_public)
  end

  def all_social_accounts(only_public = true)
    nested_values(social_accounts, only_public) do |name|
      h.auto_link(name)
    end
  end

  def nested_values(values, only_public)
    html = values.collect do |v|
      if !only_public || v.public?
        val = block_given? ? yield(v.value) : v.value
        h.value_with_muted(val, v.label)
      end
    end.compact

    html = h.safe_join(html, br)
    content_tag(:p, html) if html.present?
  end

  private

  def br
    h.tag(:br)
  end

  def prepend_complete_address(html)
  end

end
