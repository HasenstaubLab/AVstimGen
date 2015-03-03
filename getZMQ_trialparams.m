function message = getZMQ_trialparams(portnr)

% Socket to talk to server
context = zmq_ctx_new();
socket = zmq_socket(context, 'ZMQ_SUB');

address = sprintf('tcp://169.230.189.202:%d', portnr);
zmq_connect(socket, address);
topicfilter = '';
zmq_setsockopt(socket, 'ZMQ_SUBSCRIBE', topicfilter);
zmq_setsockopt(socket, 'ZMQ_RCVTIMEO', 120000);

message = [];

disp('Starting zmq_recv');

while isempty(message) % check for a message every 100ms
    message = char(zmq_recv(socket));
    WaitSecs(0.1);
end

disp(message);
zmq_disconnect(socket, address);
zmq_close(socket);
zmq_ctx_shutdown(context);
zmq_ctx_term(context);