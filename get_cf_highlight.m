function selectedFiles = get_cf_highlight

jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
jCFBrowser = jDesktop.getClient('Current Folder');
CFTable = jCFBrowser.getTable;
SelectedRows = CFTable.getSelectedRows;


for s=1:length(SelectedRows)
    selectedFiles{s}=CFTable.getValueAt(SelectedRows(s),1);
end

end