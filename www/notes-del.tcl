# /packages/intranet-notes/www/notes-del.tcl
#
# Copyright (C) 2003 - 2009 ]project-open[
#
# All rights reserved. Please check
# https://www.project-open.com/license/ for details.

# ---------------------------------------------------------------
# 1. Page Contract
# ---------------------------------------------------------------
ad_page_contract { 
    Delete Notes
    @author frank.bergmann@project-open.com
} {
    note_id:multiple,optional
    { return_url "/intranet-notes/"}
}

# ---------------------------------------------------------------
# Defaults & Security
# ---------------------------------------------------------------

# User id already verified by filters
set user_id [auth::require_login]

if {[info exists note_id]} {
    foreach id $note_id {
	db_string del_note "select im_note__delete(:id)"
    }
}

ad_returnredirect $return_url
