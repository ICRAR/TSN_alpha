module Helpers
  def fill_in_ckeditor(selector, content)
    page.should have_selector("#{selector}  iframe.cke_wysiwyg_frame")
    frame = find(selector).first('iframe.cke_wysiwyg_frame')
    within_frame(frame) do
      page.should have_selector('body p')
      js_update = %Q{
          var div = document.createElement("div");
          div.innerHTML = "#{content}";
          document.getElementsByTagName('body')[0].appendChild(div);
        }
      page.execute_script js_update
    end
  end

end