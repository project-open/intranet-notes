SELECT acs_log__debug('/packages/intranet-notes/sql/postgresql/upgrade/upgrade-5.0.4.0.0-5.0.4.0.1.sql','');



-- Create a notes plugin for the InvoiceViewPage
SELECT im_component_plugin__new (
	null,				-- plugin_id
	'im_component_plugin',		-- object_type
	now(),				-- creation_date
	null,				-- creation_invoice
	null,				-- creation_ip
	null,				-- context_id
	'Invoice Notes',			-- plugin_name
	'intranet-notes',		-- package_name
	'right',			-- location
	'/intranet-invoices/view',		-- page_url
	null,				-- view_name
	90,				-- sort_order
	'im_notes_component -object_id $invoice_id'	-- component_tcl
);

update im_component_plugins 
set title_tcl = 'lang::message::lookup "" intranet-notes.Invoice_Notes "Invoice Notes"'
where plugin_name = 'Invoice Notes';

