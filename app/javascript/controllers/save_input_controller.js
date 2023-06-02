import { Controller } from "stimulus"
import Rails from '@rails/ujs'

export default class extends Controller {
  static targets = ['input_field']

  // { user: { host_video: '1' }}
  save_changes(event) {
    let data = new FormData()
    // user[host_video]
    data.append(this.input_fieldTarget.name, this.value())

    Rails.ajax({
      type: 'PATCH',
      url: this.url(),
      dataType: 'json',
      data: data,
      success: function (response) { console.log('Setting saved.') },
      error: function (response) { console.log('Setting could not be saved.')}
    })
  }

  value() {
    switch (this.input_fieldTarget.type) {
      case "checkbox":
        return this.input_fieldTarget.checked == true ? 1 : 0
      case "select-one":
    }
  }

  url() {
    return this.input_fieldTarget.closest('form').getAttribute('action');
  }
}