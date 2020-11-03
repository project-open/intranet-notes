<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">@context_bar;literal@</property>
<property name="main_navbar_label">notes</property>
<property name="left_navbar">@left_navbar_html;literal@</property>

<script type="text/javascript" <if @::__csp_nonce@ not nil>nonce="@::__csp_nonce;literal@"</if>>
window.addEventListener('load', function() {
     document.getElementById('list_check_all').addEventListener('click', function() { acs_ListCheckAll('notes_list', this.checked) });
});
</script>

<listtemplate name="@list_id@"></listtemplate>

