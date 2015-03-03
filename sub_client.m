function sub_client(varargin)
    % Temperature informant
    %
    % Example borrowed from
    % http://learning-0mq-with-pyzmq.readthedocs.org/en/latest/pyzmq/patterns/pubsub.html
    %
    % This informant will collect 5 temperature updates from a weather server and
    % calculate the average

    port = 5575;
    if (nargin > 0)
        port =  varargin{1};
    end

    if (nargin > 1)
        port1 =  varargin{2};
    end

    % Socket to talk to server
    context = zmq_ctx_new();
    socket = zmq_socket(context, 'ZMQ_SUB');    
    
    % Subscribe to the first weather server
    fprintf('Collecting updates from weather server...\n');
%     address = sprintf('tcp://localhost:%d', port);
    address = sprintf('tcp://169.230.189.202:%d', port);
    zmq_connect(socket, address);

    if (nargin > 1)
        % Subscribe to the second weather server if required
        % This will make the client receive updates from both servers
        address = sprintf('tcp://localhost:%d', port1);
        zmq_connect(socket, address1);
    end

    % Subscribe to receive updates from a brasilian CEP
    % This will filter messages thata starts with the required string
    topicfilter = '15200';
    topicfilter = ''; 
    zmq_setsockopt(socket, 'ZMQ_SUBSCRIBE', topicfilter);
 zmq_setsockopt(socket, 'ZMQ_RCVTIMEO', 120000);
    % Process 5 updates
    total = 0;
    for update = 1:1
        disp('Starting zmq_recv'); 
        message = char(zmq_recv(socket));
        keyboard
        % message = zmq_recv(socket); 
       % parts = strsplit(message);
        parts = regexp(message,'\s', 'split'); 
        [topic, data] = parts{:};
        total = total + str2double(data);
        fprintf('%s %s\n', topic, data);
    end

    fprintf('\nAverage temperature for region with CEP starting with ''%s'' was:\n\n%g�C\n', topicfilter, total/update);

    zmq_disconnect(socket, address);
    if (nargin > 1)
        zmq_disconnect(socket, address1);
    end

    zmq_close(socket);

    zmq_ctx_shutdown(context);
    zmq_ctx_term(context);
end