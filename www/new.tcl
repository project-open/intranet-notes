# /packages/intranet-notes/www/new.tcl
#
# Copyright (C) 2003-2006 ]project-open[
#
# All rights reserved. Please check
# https://www.project-open.com/license/ for details.

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    New page is basic...
    @author all@devcon.project-open.com
} {
    note_id:integer,optional
    {object_id:integer "" }
    {note ""}
    {return_url "/intranet-notes/index"}
    {form_mode "edit"}
}

# ---------------------------------------------------------------
# Defaults & Security
# ---------------------------------------------------------------

set user_id [auth::require_login]
set page_title [_ intranet-notes.Notes_creation]
if {[info exists note_id]} { set page_title [lang::message::lookup "" intranet-notes.Note Note] }
set context_bar [im_context_bar $page_title]

# We can determine the ID of the "container object" from the
# note data, if the note_id is there (viewing an existing note).
if {[info exists note_id] && "" == $object_id} {
    set object_id [db_string oid "select object_id from im_notes where note_id = :note_id" -default ""]
}


# Check if the note was changed outside of ]po[...
if {[info exists note_id]} {
    im_audit -object_id $note_id -action view
}


# ---------------------------------------------------------------
# Create the Form
# ---------------------------------------------------------------

set form_id "form"
ad_form \
    -name $form_id \
    -mode $form_mode \
    -export "object_id return_url" \
    -form {
	note_id:key
    }


# ---------------------------------------------
# Add DynFields to the form
# ---------------------------------------------

set dynfield_note_type_id ""
if {[info exists note_type_id]} { set dynfield_note_type_id $note_type_id}

set dynfield_note_id ""
if {[info exists note_id]} { set dynfield_note_id $note_id }

im_dynfield::append_attributes_to_form \
    -form_display_mode $form_mode \
    -object_subtype_id $dynfield_note_type_id \
    -object_type "im_note" \
    -form_id $form_id \
    -object_id $dynfield_note_id


set standard_fields {
	{note_type_id:text(im_category_tree) {label "[lang::message::lookup {} intranet-notes.Notes_Type Type]"} {custom {category_type "Intranet Notes Type" translate_p 1 package_key intranet-notes include_empty_p 0}} }
	{note:text(textarea) {label "[lang::message::lookup {} intranet-notes.Notes_Note Note]"} {html {cols 60 rows 8} }}
}
foreach standard_field $standard_fields {
    set field_name [lindex [split [lindex $standard_field 0] ":"] 0]
    if {![template::element::exists $form_id $field_name]} {
	ad_form -extend -name $form_id -form [list $standard_field]
    }
}


# ---------------------------------------------------------------
# Define Form Actions
# ---------------------------------------------------------------

ad_form -extend -name $form_id \
    -select_query {

	select	*
	from	im_notes
	where	note_id = :note_id

    } -new_data {

        set note [string trim $note]
        set duplicate_note_sql "
                select  count(*)
                from    im_notes
                where   object_id = :object_id and note = :note
        "
        if {[db_string dup $duplicate_note_sql]} {
            ad_return_complaint 1 "<b>[lang::message::lookup "" intranet-notes.Duplicate_note "Duplicate note"]</b>:<br>
            [lang::message::lookup "" intranet-notes.Duplicate_note_msg "
	    	There is already the same note available for the specified object.
	    "]"
	    ad_script_abort
        }

	set note_id [db_exec_plsql create_note "
		SELECT im_note__new(
			:note_id,
			'im_note',
			now(),
			:user_id,
			'[ad_conn peeraddr]',
			null,
			:note,
			:object_id,
			:note_type_id,
			[im_note_status_active]
		)
        "]

        im_dynfield::attribute_store \
            -object_type "im_note" \
            -object_id $note_id \
            -form_id $form_id

	im_audit -object_id $note_id -action after_create

    } -edit_data {

        set note [string trim $note]
	db_dml edit_note "
		update im_notes
		set note = :note
		where note_id = :note_id
	"
        im_dynfield::attribute_store \
            -object_type "im_note" \
            -object_id $note_id \
            -form_id $form_id

	# ad_return_complaint 1 "im_audit -object_id $note_id -action after_update"
	im_audit -object_id $note_id -action after_update

    } -after_submit {
	ad_returnredirect $return_url
	ad_script_abort
    }


