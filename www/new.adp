<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">@context_bar;literal@</property>
<property name="main_navbar_label">notes</property>

<formtemplate id=form></formtemplate>


<if @form_mode@ eq "display">
<h2>Notes Audit</h2>
<%= [im_audit_component -object_id $note_id] %>
</if>