
function publ_bytes = zmqPubMsg(socket, msg)
%publ_bytes = zmqPubMsg(socket, msg)


msg_len_tot = length(msg);
if msg_len_tot>255 %multi-part
    % multipart_msg = 1;
    nr_msgs = ceil(msg_len_tot/255);
    str_ind = 1;
    bytes_sent = zeros(1,nr_msgs);
    msg_split = cell(nr_msgs, 1);
    for i = 1:nr_msgs
        if i == nr_msgs
            msg_split{i} = msg(str_ind:end);
            bytes_sent(i) = zmq_send(socket, uint8(msg_split{i}));
        else
            msg_split{i} = msg(str_ind:str_ind+254);
            bytes_sent(i) = zmq_send(socket, uint8(msg_split{i}), 'ZMQ_SNDMORE');
            str_ind = str_ind+255;
        end
    end
    publ_bytes(1) = sum(bytes_sent);
else
    multipart_msg = 0;
    publ_bytes(1) = zmq_send(socket, uint8(msg));
end