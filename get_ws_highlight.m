function selectedVars = get_ws_highlight

jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
jWSBrowser = jDesktop.getClient('Workspace');
WSTable=jWSBrowser.getComponent(0).getComponent(0).getComponent(0);
selectedRows=WSTable.getSelectedRows;

for s=1:length(selectedRows)
    selectedVars{s}=WSTable.getValueAt(selectedRows(s),0);
end