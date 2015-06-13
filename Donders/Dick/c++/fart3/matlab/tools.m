%=========================================================================
%                           Setup connection
%=========================================================================
function ret = tools(cmd)
    data(1) = 2;
    data(2) = cmd.TCPinit;
%     
%     result = mexServer(dataRecord);
%     if (result == data.TCPinit)
%         set(data.server_edit_status,'String','connect-ok');
%         data.server_status = 1;    % connected-1
%     else
%         set(data.server_edit_status,'String','error');
%         data.server_status = -1;   % error
%     end
%     if (result > 0)
%         dataRecord(1) = 2;
%         dataRecord(2) = data.TCPquery;
%         result = mexServer(dataRecord);
%         if (result == data.TCPquery)
%             set(data.server_edit_status,'String','running');
%             data.server_status = 2;    % connected-2
%         else
%             set(data.server_edit_status,'String','error');
%             data.server_status = -1;   % error
%         end
%     end
%     set(data.server_push_start,'Visible','off');
data

ret = 1;
end

