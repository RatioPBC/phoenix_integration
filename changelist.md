## phoenix_integration Changelist

### 0.8.0
  * Fairly large update to handle forms with hidden fields. This update treats forms as parsed
    trees and has more informative output, and is generally more flexible. This entire update
    is brought to you by the hard work of Brian Marick (@marick on GitHub). Thank you!

### 0.7.0
  * __Marking this as 0.7.0 because it is requires a minor version update to Floki. Otherwise
    the actual changes in phoenix_markdown are more patch-like...__
  * Changed a private functions "is_struct" to "do_is_struct" to avoid a conflict with
    the new Kernel.is_struct function in Elixir v1.10
  * Change the minimum required version of Floki to 0.24.0 and then use the new 
    Floki.parse_document pattern to get rid of the deprecation warnings.
  * add .formatter.exs and format the code

### 0.6.0
  * Moved from Poison to Jason for json parsing

### 0.5.3
  * Merged pull request #23 from jonasschmidt to support deeply nested forms.
  * Add Travis tests for elixir 1.7

### 0.5.2
  * Merged pull request #22 from wooga to allow single-character input names in forms

### 0.5.1
  * fixed bug (issue #20) where it didn't find radio input fields if none were intially checked
  * removed dependency on DeepMerge

### 0.5.0
  * added Request.click_button to find and click simple buttons on the page
  * added Request.follow_button to find, click, and follow simple buttons on the page
  * improved error message when usinga link, while asking for the wrong method.

### 0.4.1
  * run the code through the elixir 1.6 formatter
  * update travis tests

### 0.4.0
  * fix issue #11, was incorrectly reading the method of the form in the case of a get
  * add the fetch_form function to the Request module
  * support for nested forms. Thank you https://github.com/bitboxer
  * support follow_link for phoenix_html 2.10. Thank you https://github.com/andreapavoni
  * bump up to Elixir 1.4
  * update docs

### 0.3.0
  * added a new :value assertion type that checks the result of a callback for truthyness
  * relaxed requirement on floki version

### 0.2.0
  * Updated Dependencies to use version 0.13 of Floki (the html parsing enging)
  * Use updated Floki syntax when searching for links and forms by text content.
  * Errors while running a form test now display the path that was associated with the form.
    should aid in resolving issues on pages with more than one form.
    Thank you goes to https://github.com/Mbuckley0 for sorting this out.
  * Change the readme to suggest only loading phoenix_integration in test mode
  * Added support for DateTime fields in forms. Again thank you https://github.com/Mbuckley0
    for adding this feature in.

### 0.1.2
  * Add support for file upload fields in forms

### 0.1.1
  * Added `:assigns` option to both `Assertions.assert_response` and `Assertions.refute_response`.
  * Added `Requests.follow_fn`
  * cleaning up readme and docs

### 0.1.0
  First release