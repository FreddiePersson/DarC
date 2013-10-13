function  [parsed_xml] = parse_lv_xml(str)

[main_body_pos, main_bodys_str] = fnd_node(str,'Cluster');

[NumElts_pos, NumElts_str] = fnd_node(main_bodys_str,'NumElts');
NumElts = str2num(char(NumElts_str));

parsed_xml = [];

cursor_pos = 1;
for i=1:NumElts
    
    [node_pos, node_str] = fnd_node(main_bodys_str(cursor_pos:end),'DBL');
    [name_pos, name_str] = fnd_node(node_str,'Name');
    [val_pos, val_str] = fnd_node(node_str,'Val');
    cursor_pos = cursor_pos+node_pos.idx_end;
    
    fieldname = regexprep(char(name_str),' ','_');
    parsed_xml = setfield(parsed_xml, fieldname, str2num(char(val_str)) );
end


    function [pos contents] = fnd_node(str, node_name)
        idx_init = strfind(str,['<' node_name '>']);
        
        idx_end = strfind(str,['</' node_name '>']);
        
        pos.idx_start = idx_init(1)+length(['<' node_name '>']); %start of the content of the node
        pos.size = idx_end(1)-pos.idx_start-1; % size of the content of the node
        pos.idx_end = idx_end(1)+length(['</' node_name '>']); %ending of the node
        
        contents = str(pos.idx_start + (0:pos.size) );
        
    end

end