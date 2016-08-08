require "./lib"
require "../common"
require "../system"
module SF
  extend self
  # Base class for all the socket types
  #
  #
  #
  # This class mainly defines internal stuff to be used by
  # derived classes.
  #
  # The only public features that it defines, and which
  # is therefore common to all the socket classes, is the
  # blocking state. All sockets can be set as blocking or
  # non-blocking.
  #
  # In blocking mode, socket functions will hang until
  # the operation completes, which means that the entire
  # program (well, in fact the current thread if you use
  # multiple ones) will be stuck waiting for your socket
  # operation to complete.
  #
  # In non-blocking mode, all the socket functions will
  # return immediately. If the socket is not ready to complete
  # the requested operation, the function simply returns
  # the proper status code (Socket::NotReady).
  #
  # The default mode, which is blocking, is the one that is
  # generally used, in combination with threads or selectors.
  # The non-blocking mode is rather used in real-time
  # applications that run an endless loop that can poll
  # the socket often enough, and cannot afford blocking
  # this loop.
  #
  # *See also:* `SF::TcpListener`, `SF::TcpSocket`, `SF::UdpSocket`
  class Socket
    @_socket : VoidCSFML::Socket_Buffer = VoidCSFML::Socket_Buffer.new(0u8)
    # Status codes that may be returned by socket functions
    enum Status
      # The socket has sent / received the data
      Done
      # The socket is not ready to send / receive data yet
      NotReady
      # The socket sent a part of the data
      Partial
      # The TCP socket has been disconnected
      Disconnected
      # An unexpected error happened
      Error
    end
    _sf_enum Socket::Status
    # Some special values used by sockets
    # Special value that tells the system to pick any available port
    AnyPort = 0
    # Destructor
    def finalize()
      VoidCSFML.socket_finalize(to_unsafe)
    end
    # Set the blocking state of the socket
    #
    # In blocking mode, calls will not return until they have
    # completed their task. For example, a call to Receive in
    # blocking mode won't return until some data was actually
    # received.
    # In non-blocking mode, calls will always return immediately,
    # using the return code to signal whether there was data
    # available or not.
    # By default, all sockets are blocking.
    #
    # * *blocking* - True to set the socket as blocking, false for non-blocking
    #
    # *See also:* isBlocking
    def blocking=(blocking : Bool)
      VoidCSFML.socket_setblocking_GZq(to_unsafe, blocking)
    end
    # Tell whether the socket is in blocking or non-blocking mode
    #
    # *Returns:* True if the socket is blocking, false otherwise
    #
    # *See also:* setBlocking
    def blocking?() : Bool
      VoidCSFML.socket_isblocking(to_unsafe, out result)
      return result
    end
    # Types of protocols that the socket can use
    enum Type
      # TCP protocol
      Tcp
      # UDP protocol
      Udp
    end
    _sf_enum Socket::Type
    include NonCopyable
    # :nodoc:
    def to_unsafe()
      pointerof(@_socket).as(Void*)
    end
    # :nodoc:
    def inspect(io)
      to_s(io)
    end
  end
  # Specialized socket using the TCP protocol
  #
  #
  #
  # TCP is a connected protocol, which means that a TCP
  # socket can only communicate with the host it is connected
  # to. It can't send or receive anything if it is not connected.
  #
  # The TCP protocol is reliable but adds a slight overhead.
  # It ensures that your data will always be received in order
  # and without errors (no data corrupted, lost or duplicated).
  #
  # When a socket is connected to a remote host, you can
  # retrieve informations about this host with the
  # getRemoteAddress and getRemotePort functions. You can
  # also get the local port to which the socket is bound
  # (which is automatically chosen when the socket is connected),
  # with the getLocalPort function.
  #
  # Sending and receiving data can use either the low-level
  # or the high-level functions. The low-level functions
  # process a raw sequence of bytes, and cannot ensure that
  # one call to Send will exactly match one call to Receive
  # at the other end of the socket.
  #
  # The high-level interface uses packets (see `SF::Packet`),
  # which are easier to use and provide more safety regarding
  # the data that is exchanged. You can look at the `SF::Packet`
  # class to get more details about how they work.
  #
  # The socket is automatically disconnected when it is destroyed,
  # but if you want to explicitly close the connection while
  # the socket instance is still alive, you can call disconnect.
  #
  # Usage example:
  # ```c++
  # // ----- The client -----
  #
  # // Create a socket and connect it to 192.168.1.50 on port 55001
  # sf::TcpSocket socket;
  # socket.connect("192.168.1.50", 55001);
  #
  # // Send a message to the connected host
  # std::string message = "Hi, I am a client";
  # socket.send(message.c_str(), message.size() + 1);
  #
  # // Receive an answer from the server
  # char buffer[1024];
  # std::size_t received = 0;
  # socket.receive(buffer, sizeof(buffer), received);
  # std::cout << "The server said: " << buffer << std::endl;
  #
  # // ----- The server -----
  #
  # // Create a listener to wait for incoming connections on port 55001
  # sf::TcpListener listener;
  # listener.listen(55001);
  #
  # // Wait for a connection
  # sf::TcpSocket socket;
  # listener.accept(socket);
  # std::cout << "New client connected: " << socket.getRemoteAddress() << std::endl;
  #
  # // Receive a message from the client
  # char buffer[1024];
  # std::size_t received = 0;
  # socket.receive(buffer, sizeof(buffer), received);
  # std::cout << "The client said: " << buffer << std::endl;
  #
  # // Send an answer
  # std::string message = "Welcome, client";
  # socket.send(message.c_str(), message.size() + 1);
  # ```
  #
  # *See also:* `SF::Socket`, `SF::UdpSocket`, `SF::Packet`
  class TcpSocket < Socket
    @_tcpsocket : VoidCSFML::TcpSocket_Buffer = VoidCSFML::TcpSocket_Buffer.new(0u8)
    # Default constructor
    def initialize()
      @_socket = uninitialized VoidCSFML::Socket_Buffer
      @_tcpsocket = uninitialized VoidCSFML::TcpSocket_Buffer
      VoidCSFML.tcpsocket_initialize(to_unsafe)
    end
    # Get the port to which the socket is bound locally
    #
    # If the socket is not connected, this function returns 0.
    #
    # *Returns:* Port to which the socket is bound
    #
    # *See also:* connect, getRemotePort
    def local_port() : UInt16
      VoidCSFML.tcpsocket_getlocalport(to_unsafe, out result)
      return result
    end
    # Get the address of the connected peer
    #
    # It the socket is not connected, this function returns
    # `SF::IpAddress::None`.
    #
    # *Returns:* Address of the remote peer
    #
    # *See also:* getRemotePort
    def remote_address() : IpAddress
      result = IpAddress.allocate
      VoidCSFML.tcpsocket_getremoteaddress(to_unsafe, result)
      return result
    end
    # Get the port of the connected peer to which
    #        the socket is connected
    #
    # If the socket is not connected, this function returns 0.
    #
    # *Returns:* Remote port to which the socket is connected
    #
    # *See also:* getRemoteAddress
    def remote_port() : UInt16
      VoidCSFML.tcpsocket_getremoteport(to_unsafe, out result)
      return result
    end
    # Connect the socket to a remote peer
    #
    # In blocking mode, this function may take a while, especially
    # if the remote peer is not reachable. The last parameter allows
    # you to stop trying to connect after a given timeout.
    # If the socket was previously connected, it is first disconnected.
    #
    # * *remote_address* - Address of the remote peer
    # * *remote_port* -    Port of the remote peer
    # * *timeout* -       Optional maximum time to wait
    #
    # *Returns:* Status code
    #
    # *See also:* disconnect
    def connect(remote_address : IpAddress, remote_port : Int, timeout : Time = Time::Zero) : Socket::Status
      VoidCSFML.tcpsocket_connect_BfEbxif4T(to_unsafe, remote_address, LibC::UShort.new(remote_port), timeout, out result)
      return Socket::Status.new(result)
    end
    # Disconnect the socket from its remote peer
    #
    # This function gracefully closes the connection. If the
    # socket is not connected, this function has no effect.
    #
    # *See also:* connect
    def disconnect()
      VoidCSFML.tcpsocket_disconnect(to_unsafe)
    end
    # Send raw data to the remote peer
    #
    # To be able to handle partial sends over non-blocking
    # sockets, use the send(const void*, std::size_t, std::size_t&)
    # overload instead.
    # This function will fail if the socket is not connected.
    #
    # * *data* - Pointer to the sequence of bytes to send
    # * *size* - Number of bytes to send
    #
    # *Returns:* Status code
    #
    # *See also:* receive
    def send(data : Slice) : Socket::Status
      VoidCSFML.tcpsocket_send_5h8vgv(to_unsafe, data, data.bytesize, out result)
      return Socket::Status.new(result)
    end
    # Send raw data to the remote peer
    #
    # This function will fail if the socket is not connected.
    #
    # * *data* - Pointer to the sequence of bytes to send
    # * *size* - Number of bytes to send
    # * *sent* - The number of bytes sent will be written here
    #
    # *Returns:* Status code
    #
    # *See also:* receive
    def send(data : Slice) : {Socket::Status, LibC::SizeT}
      VoidCSFML.tcpsocket_send_5h8vgvi49(to_unsafe, data, data.bytesize, out sent, out result)
      return Socket::Status.new(result), sent
    end
    # Receive raw data from the remote peer
    #
    # In blocking mode, this function will wait until some
    # bytes are actually received.
    # This function will fail if the socket is not connected.
    #
    # * *data* -     Pointer to the array to fill with the received bytes
    # * *size* -     Maximum number of bytes that can be received
    # * *received* - This variable is filled with the actual number of bytes received
    #
    # *Returns:* Status code
    #
    # *See also:* send
    def receive(data : Slice) : {Socket::Status, LibC::SizeT}
      VoidCSFML.tcpsocket_receive_xALvgvi49(to_unsafe, data, data.bytesize, out received, out result)
      return Socket::Status.new(result), received
    end
    # Send a formatted packet of data to the remote peer
    #
    # In non-blocking mode, if this function returns `SF::Socket::Partial`,
    # you *must* retry sending the same unmodified packet before sending
    # anything else in order to guarantee the packet arrives at the remote
    # peer uncorrupted.
    # This function will fail if the socket is not connected.
    #
    # * *packet* - Packet to send
    #
    # *Returns:* Status code
    #
    # *See also:* receive
    def send(packet : Packet) : Socket::Status
      VoidCSFML.tcpsocket_send_jyF(to_unsafe, packet, out result)
      return Socket::Status.new(result)
    end
    # Receive a formatted packet of data from the remote peer
    #
    # In blocking mode, this function will wait until the whole packet
    # has been received.
    # This function will fail if the socket is not connected.
    #
    # * *packet* - Packet to fill with the received data
    #
    # *Returns:* Status code
    #
    # *See also:* send
    def receive(packet : Packet) : Socket::Status
      VoidCSFML.tcpsocket_receive_jyF(to_unsafe, packet, out result)
      return Socket::Status.new(result)
    end
    # :nodoc:
    def blocking=(blocking : Bool)
      VoidCSFML.tcpsocket_setblocking_GZq(to_unsafe, blocking)
    end
    # :nodoc:
    def blocking?() : Bool
      VoidCSFML.tcpsocket_isblocking(to_unsafe, out result)
      return result
    end
    # :nodoc:
    def to_unsafe()
      pointerof(@_socket).as(Void*)
    end
    # :nodoc:
    def inspect(io)
      to_s(io)
    end
  end
  # A FTP client
  #
  # Utility class for exchanging datas with the server
  #        on the data channel
  #
  #
  #
  # `SF::Ftp` is a very simple FTP client that allows you
  # to communicate with a FTP server. The FTP protocol allows
  # you to manipulate a remote file system (list files,
  # upload, download, create, remove, ...).
  #
  # Using the FTP client consists of 4 parts:
  # * Connecting to the FTP server
  # * Logging in (either as a registered user or anonymously)
  # * Sending commands to the server
  # * Disconnecting (this part can be done implicitly by the destructor)
  #
  # Every command returns a FTP response, which contains the
  # status code as well as a message from the server. Some
  # commands such as getWorkingDirectory() and getDirectoryListing()
  # return additional data, and use a class derived from
  # `SF::Ftp::Response` to provide this data. The most often used
  # commands are directly provided as member functions, but it is
  # also possible to use specific commands with the sendCommand() function.
  #
  # Note that response statuses &gt;= 1000 are not part of the FTP standard,
  # they are generated by SFML when an internal error occurs.
  #
  # All commands, especially upload and download, may take some
  # time to complete. This is important to know if you don't want
  # to block your application while the server is completing
  # the task.
  #
  # Usage example:
  # ```c++
  # // Create a new FTP client
  # sf::Ftp ftp;
  #
  # // Connect to the server
  # sf::Ftp::Response response = ftp.connect("ftp://ftp.myserver.com");
  # if (response.isOk())
  #     std::cout << "Connected" << std::endl;
  #
  # // Log in
  # response = ftp.login("laurent", "dF6Zm89D");
  # if (response.isOk())
  #     std::cout << "Logged in" << std::endl;
  #
  # // Print the working directory
  # sf::Ftp::DirectoryResponse directory = ftp.getWorkingDirectory();
  # if (directory.isOk())
  #     std::cout << "Working directory: " << directory.getDirectory() << std::endl;
  #
  # // Create a new directory
  # response = ftp.createDirectory("files");
  # if (response.isOk())
  #     std::cout << "Created new directory" << std::endl;
  #
  # // Upload a file to this new directory
  # response = ftp.upload("local-path/file.txt", "files", sf::Ftp::Ascii);
  # if (response.isOk())
  #     std::cout << "File uploaded" << std::endl;
  #
  # // Send specific commands (here: FEAT to list supported FTP features)
  # response = ftp.sendCommand("FEAT");
  # if (response.isOk())
  #     std::cout << "Feature list:\n" << response.getMessage() << std::endl;
  #
  # // Disconnect from the server (optional)
  # ftp.disconnect();
  # ```
  class Ftp
    @_ftp : VoidCSFML::Ftp_Buffer = VoidCSFML::Ftp_Buffer.new(0u8)
    def initialize()
      @_ftp = uninitialized VoidCSFML::Ftp_Buffer
      VoidCSFML.ftp_initialize(to_unsafe)
    end
    # Enumeration of transfer modes
    enum TransferMode
      # Binary mode (file is transfered as a sequence of bytes)
      Binary
      # Text mode using ASCII encoding
      Ascii
      # Text mode using EBCDIC encoding
      Ebcdic
    end
    _sf_enum Ftp::TransferMode
    # Define a FTP response
    class Response
      @_ftp_response : VoidCSFML::Ftp_Response_Buffer = VoidCSFML::Ftp_Response_Buffer.new(0u8)
      # Status codes possibly returned by a FTP response
      enum Status
        # Restart marker reply
        RestartMarkerReply = 110
        # Service ready in N minutes
        ServiceReadySoon = 120
        # Data connection already opened, transfer starting
        DataConnectionAlreadyOpened = 125
        # File status ok, about to open data connection
        OpeningDataConnection = 150
        # Command ok
        Ok = 200
        # Command not implemented
        PointlessCommand = 202
        # System status, or system help reply
        SystemStatus = 211
        # Directory status
        DirectoryStatus = 212
        # File status
        FileStatus = 213
        # Help message
        HelpMessage = 214
        # NAME system type, where NAME is an official system name from the list in the Assigned Numbers document
        SystemType = 215
        # Service ready for new user
        ServiceReady = 220
        # Service closing control connection
        ClosingConnection = 221
        # Data connection open, no transfer in progress
        DataConnectionOpened = 225
        # Closing data connection, requested file action successful
        ClosingDataConnection = 226
        # Entering passive mode
        EnteringPassiveMode = 227
        # User logged in, proceed. Logged out if appropriate
        LoggedIn = 230
        # Requested file action ok
        FileActionOk = 250
        # PATHNAME created
        DirectoryOk = 257
        # User name ok, need password
        NeedPassword = 331
        # Need account for login
        NeedAccountToLogIn = 332
        # Requested file action pending further information
        NeedInformation = 350
        # Service not available, closing control connection
        ServiceUnavailable = 421
        # Can't open data connection
        DataConnectionUnavailable = 425
        # Connection closed, transfer aborted
        TransferAborted = 426
        # Requested file action not taken
        FileActionAborted = 450
        # Requested action aborted, local error in processing
        LocalError = 451
        # Requested action not taken; insufficient storage space in system, file unavailable
        InsufficientStorageSpace = 452
        # Syntax error, command unrecognized
        CommandUnknown = 500
        # Syntax error in parameters or arguments
        ParametersUnknown = 501
        # Command not implemented
        CommandNotImplemented = 502
        # Bad sequence of commands
        BadCommandSequence = 503
        # Command not implemented for that parameter
        ParameterNotImplemented = 504
        # Not logged in
        NotLoggedIn = 530
        # Need account for storing files
        NeedAccountToStore = 532
        # Requested action not taken, file unavailable
        FileUnavailable = 550
        # Requested action aborted, page type unknown
        PageTypeUnknown = 551
        # Requested file action aborted, exceeded storage allocation
        NotEnoughMemory = 552
        # Requested action not taken, file name not allowed
        FilenameNotAllowed = 553
        # Not part of the FTP standard, generated by SFML when a received response cannot be parsed
        InvalidResponse = 1000
        # Not part of the FTP standard, generated by SFML when the low-level socket connection with the server fails
        ConnectionFailed = 1001
        # Not part of the FTP standard, generated by SFML when the low-level socket connection is unexpectedly closed
        ConnectionClosed = 1002
        # Not part of the FTP standard, generated by SFML when a local file cannot be read or written
        InvalidFile = 1003
      end
      _sf_enum Ftp::Response::Status
      # Default constructor
      #
      # This constructor is used by the FTP client to build
      # the response.
      #
      # * *code* -    Response status code
      # * *message* - Response message
      def initialize(code : Ftp::Response::Status = InvalidResponse, message : String = "")
        @_ftp_response = uninitialized VoidCSFML::Ftp_Response_Buffer
        VoidCSFML.ftp_response_initialize_nyWzkC(to_unsafe, code, message.bytesize, message)
      end
      # Check if the status code means a success
      #
      # This function is defined for convenience, it is
      # equivalent to testing if the status code is &lt; 400.
      #
      # *Returns:* True if the status is a success, false if it is a failure
      def ok?() : Bool
        VoidCSFML.ftp_response_isok(to_unsafe, out result)
        return result
      end
      # Get the status code of the response
      #
      # *Returns:* Status code
      def status() : Ftp::Response::Status
        VoidCSFML.ftp_response_getstatus(to_unsafe, out result)
        return Ftp::Response::Status.new(result)
      end
      # Get the full message contained in the response
      #
      # *Returns:* The response message
      def message() : String
        VoidCSFML.ftp_response_getmessage(to_unsafe, out result)
        return String.new(result)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@_ftp_response).as(Void*)
      end
      # :nodoc:
      def inspect(io)
        to_s(io)
      end
      # :nodoc:
      def initialize(copy : Ftp::Response)
        @_ftp_response = uninitialized VoidCSFML::Ftp_Response_Buffer
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.ftp_response_initialize_lXv(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Specialization of FTP response returning a directory
    class DirectoryResponse < Response
      @_ftp_directoryresponse : VoidCSFML::Ftp_DirectoryResponse_Buffer = VoidCSFML::Ftp_DirectoryResponse_Buffer.new(0u8)
      # Default constructor
      #
      # * *response* - Source response
      def initialize(response : Ftp::Response)
        @_ftp_response = uninitialized VoidCSFML::Ftp_Response_Buffer
        @_ftp_directoryresponse = uninitialized VoidCSFML::Ftp_DirectoryResponse_Buffer
        VoidCSFML.ftp_directoryresponse_initialize_lXv(to_unsafe, response)
      end
      # Get the directory returned in the response
      #
      # *Returns:* Directory name
      def directory() : String
        VoidCSFML.ftp_directoryresponse_getdirectory(to_unsafe, out result)
        return String.new(result)
      end
      # :nodoc:
      def ok?() : Bool
        VoidCSFML.ftp_directoryresponse_isok(to_unsafe, out result)
        return result
      end
      # :nodoc:
      def status() : Ftp::Response::Status
        VoidCSFML.ftp_directoryresponse_getstatus(to_unsafe, out result)
        return Ftp::Response::Status.new(result)
      end
      # :nodoc:
      def message() : String
        VoidCSFML.ftp_directoryresponse_getmessage(to_unsafe, out result)
        return String.new(result)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@_ftp_response).as(Void*)
      end
      # :nodoc:
      def inspect(io)
        to_s(io)
      end
      # :nodoc:
      def initialize(copy : Ftp::DirectoryResponse)
        @_ftp_response = uninitialized VoidCSFML::Ftp_Response_Buffer
        @_ftp_directoryresponse = uninitialized VoidCSFML::Ftp_DirectoryResponse_Buffer
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.ftp_directoryresponse_initialize_Zyp(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Specialization of FTP response returning a
    #        filename listing
    class ListingResponse < Response
      @_ftp_listingresponse : VoidCSFML::Ftp_ListingResponse_Buffer = VoidCSFML::Ftp_ListingResponse_Buffer.new(0u8)
      # Default constructor
      #
      # * *response* -  Source response
      # * *data* -      Data containing the raw listing
      def initialize(response : Ftp::Response, data : String)
        @_ftp_response = uninitialized VoidCSFML::Ftp_Response_Buffer
        @_ftp_listingresponse = uninitialized VoidCSFML::Ftp_ListingResponse_Buffer
        VoidCSFML.ftp_listingresponse_initialize_lXvzkC(to_unsafe, response, data.bytesize, data)
      end
      # Return the array of directory/file names
      #
      # *Returns:* Array containing the requested listing
      def listing() : Array(String)
        VoidCSFML.ftp_listingresponse_getlisting(to_unsafe, out result, out result_size)
        return Array.new(result_size.to_i) { |i| String.new(result[i]) }
      end
      # :nodoc:
      def ok?() : Bool
        VoidCSFML.ftp_listingresponse_isok(to_unsafe, out result)
        return result
      end
      # :nodoc:
      def status() : Ftp::Response::Status
        VoidCSFML.ftp_listingresponse_getstatus(to_unsafe, out result)
        return Ftp::Response::Status.new(result)
      end
      # :nodoc:
      def message() : String
        VoidCSFML.ftp_listingresponse_getmessage(to_unsafe, out result)
        return String.new(result)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@_ftp_response).as(Void*)
      end
      # :nodoc:
      def inspect(io)
        to_s(io)
      end
      # :nodoc:
      def initialize(copy : Ftp::ListingResponse)
        @_ftp_response = uninitialized VoidCSFML::Ftp_Response_Buffer
        @_ftp_listingresponse = uninitialized VoidCSFML::Ftp_ListingResponse_Buffer
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.ftp_listingresponse_initialize_2ho(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Destructor
    #
    # Automatically closes the connection with the server if
    # it is still opened.
    def finalize()
      VoidCSFML.ftp_finalize(to_unsafe)
    end
    # Connect to the specified FTP server
    #
    # The port has a default value of 21, which is the standard
    # port used by the FTP protocol. You shouldn't use a different
    # value, unless you really know what you do.
    # This function tries to connect to the server so it may take
    # a while to complete, especially if the server is not
    # reachable. To avoid blocking your application for too long,
    # you can use a timeout. The default value, Time::Zero, means that the
    # system timeout will be used (which is usually pretty long).
    #
    # * *server* -  Name or address of the FTP server to connect to
    # * *port* -    Port used for the connection
    # * *timeout* - Maximum time to wait
    #
    # *Returns:* Server response to the request
    #
    # *See also:* disconnect
    def connect(server : IpAddress, port : Int = 21, timeout : Time = Time::Zero) : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_connect_BfEbxif4T(to_unsafe, server, LibC::UShort.new(port), timeout, result)
      return result
    end
    # Close the connection with the server
    #
    # *Returns:* Server response to the request
    #
    # *See also:* connect
    def disconnect() : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_disconnect(to_unsafe, result)
      return result
    end
    # Log in using an anonymous account
    #
    # Logging in is mandatory after connecting to the server.
    # Users that are not logged in cannot perform any operation.
    #
    # *Returns:* Server response to the request
    def login() : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_login(to_unsafe, result)
      return result
    end
    # Log in using a username and a password
    #
    # Logging in is mandatory after connecting to the server.
    # Users that are not logged in cannot perform any operation.
    #
    # * *name* -     User name
    # * *password* - Password
    #
    # *Returns:* Server response to the request
    def login(name : String, password : String) : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_login_zkCzkC(to_unsafe, name.bytesize, name, password.bytesize, password, result)
      return result
    end
    # Send a null command to keep the connection alive
    #
    # This command is useful because the server may close the
    # connection automatically if no command is sent.
    #
    # *Returns:* Server response to the request
    def keep_alive() : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_keepalive(to_unsafe, result)
      return result
    end
    # Get the current working directory
    #
    # The working directory is the root path for subsequent
    # operations involving directories and/or filenames.
    #
    # *Returns:* Server response to the request
    #
    # *See also:* getDirectoryListing, changeDirectory, parentDirectory
    def working_directory() : Ftp::DirectoryResponse
      return @_ftp_working_directory.not_nil! if @_ftp_working_directory
      result = Ftp::DirectoryResponse.allocate
      @_ftp_working_directory = result
      VoidCSFML.ftp_getworkingdirectory(to_unsafe, result)
      return result
    end
    @_ftp_working_directory : Ftp::DirectoryResponse? = nil
    # Get the contents of the given directory
    #
    # This function retrieves the sub-directories and files
    # contained in the given directory. It is not recursive.
    # The *directory* parameter is relative to the current
    # working directory.
    #
    # * *directory* - Directory to list
    #
    # *Returns:* Server response to the request
    #
    # *See also:* getWorkingDirectory, changeDirectory, parentDirectory
    def get_directory_listing(directory : String = "") : Ftp::ListingResponse
      result = Ftp::ListingResponse.allocate
      VoidCSFML.ftp_getdirectorylisting_zkC(to_unsafe, directory.bytesize, directory, result)
      return result
    end
    # Change the current working directory
    #
    # The new directory must be relative to the current one.
    #
    # * *directory* - New working directory
    #
    # *Returns:* Server response to the request
    #
    # *See also:* getWorkingDirectory, getDirectoryListing, parentDirectory
    def change_directory(directory : String) : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_changedirectory_zkC(to_unsafe, directory.bytesize, directory, result)
      return result
    end
    # Go to the parent directory of the current one
    #
    # *Returns:* Server response to the request
    #
    # *See also:* getWorkingDirectory, getDirectoryListing, changeDirectory
    def parent_directory() : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_parentdirectory(to_unsafe, result)
      return result
    end
    # Create a new directory
    #
    # The new directory is created as a child of the current
    # working directory.
    #
    # * *name* - Name of the directory to create
    #
    # *Returns:* Server response to the request
    #
    # *See also:* deleteDirectory
    def create_directory(name : String) : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_createdirectory_zkC(to_unsafe, name.bytesize, name, result)
      return result
    end
    # Remove an existing directory
    #
    # The directory to remove must be relative to the
    # current working directory.
    # Use this function with caution, the directory will
    # be removed permanently!
    #
    # * *name* - Name of the directory to remove
    #
    # *Returns:* Server response to the request
    #
    # *See also:* createDirectory
    def delete_directory(name : String) : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_deletedirectory_zkC(to_unsafe, name.bytesize, name, result)
      return result
    end
    # Rename an existing file
    #
    # The filenames must be relative to the current working
    # directory.
    #
    # * *file* -    File to rename
    # * *new_name* - New name of the file
    #
    # *Returns:* Server response to the request
    #
    # *See also:* deleteFile
    def rename_file(file : String, new_name : String) : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_renamefile_zkCzkC(to_unsafe, file.bytesize, file, new_name.bytesize, new_name, result)
      return result
    end
    # Remove an existing file
    #
    # The file name must be relative to the current working
    # directory.
    # Use this function with caution, the file will be
    # removed permanently!
    #
    # * *name* - File to remove
    #
    # *Returns:* Server response to the request
    #
    # *See also:* renameFile
    def delete_file(name : String) : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_deletefile_zkC(to_unsafe, name.bytesize, name, result)
      return result
    end
    # Download a file from the server
    #
    # The filename of the distant file is relative to the
    # current working directory of the server, and the local
    # destination path is relative to the current directory
    # of your application.
    # If a file with the same filename as the distant file
    # already exists in the local destination path, it will
    # be overwritten.
    #
    # * *remote_file* - Filename of the distant file to download
    # * *local_path* -  The directory in which to put the file on the local computer
    # * *mode* -       Transfer mode
    #
    # *Returns:* Server response to the request
    #
    # *See also:* upload
    def download(remote_file : String, local_path : String, mode : Ftp::TransferMode = Binary) : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_download_zkCzkCJP8(to_unsafe, remote_file.bytesize, remote_file, local_path.bytesize, local_path, mode, result)
      return result
    end
    # Upload a file to the server
    #
    # The name of the local file is relative to the current
    # working directory of your application, and the
    # remote path is relative to the current directory of the
    # FTP server.
    #
    # * *local_file* -  Path of the local file to upload
    # * *remote_path* - The directory in which to put the file on the server
    # * *mode* -       Transfer mode
    #
    # *Returns:* Server response to the request
    #
    # *See also:* download
    def upload(local_file : String, remote_path : String, mode : Ftp::TransferMode = Binary) : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_upload_zkCzkCJP8(to_unsafe, local_file.bytesize, local_file, remote_path.bytesize, remote_path, mode, result)
      return result
    end
    # Send a command to the FTP server
    #
    # While the most often used commands are provided as member
    # functions in the `SF::Ftp` class, this method can be used
    # to send any FTP command to the server. If the command
    # requires one or more parameters, they can be specified
    # in *parameter.* If the server returns information, you
    # can extract it from the response using Response::getMessage().
    #
    # * *command* -   Command to send
    # * *parameter* - Command parameter
    #
    # *Returns:* Server response to the request
    def send_command(command : String, parameter : String = "") : Ftp::Response
      result = Ftp::Response.allocate
      VoidCSFML.ftp_sendcommand_zkCzkC(to_unsafe, command.bytesize, command, parameter.bytesize, parameter, result)
      return result
    end
    include NonCopyable
    # :nodoc:
    def to_unsafe()
      pointerof(@_ftp).as(Void*)
    end
    # :nodoc:
    def inspect(io)
      to_s(io)
    end
  end
  # Encapsulate an IPv4 network address
  #
  #
  #
  # `SF::IpAddress` is a utility class for manipulating network
  # addresses. It provides a set a implicit constructors and
  # conversion functions to easily build or transform an IP
  # address from/to various representations.
  #
  # Usage example:
  # ```c++
  # sf::IpAddress a0;                                     // an invalid address
  # sf::IpAddress a1 = sf::IpAddress::None;               // an invalid address (same as a0)
  # sf::IpAddress a2("127.0.0.1");                        // the local host address
  # sf::IpAddress a3 = sf::IpAddress::Broadcast;          // the broadcast address
  # sf::IpAddress a4(192, 168, 1, 56);                    // a local address
  # sf::IpAddress a5("my_computer");                      // a local address created from a network name
  # sf::IpAddress a6("89.54.1.169");                      // a distant address
  # sf::IpAddress a7("www.google.com");                   // a distant address created from a network name
  # sf::IpAddress a8 = sf::IpAddress::getLocalAddress();  // my address on the local network
  # sf::IpAddress a9 = sf::IpAddress::getPublicAddress(); // my address on the internet
  # ```
  #
  # Note that `SF::IpAddress` currently doesn't support IPv6
  # nor other types of network addresses.
  struct IpAddress
    @m_address : UInt32
    # Default constructor
    #
    # This constructor creates an empty (invalid) address
    def initialize()
      @m_address = uninitialized UInt32
      VoidCSFML.ipaddress_initialize(to_unsafe)
    end
    # Construct the address from a string
    #
    # Here *address* can be either a decimal address
    # (ex: "192.168.1.56") or a network name (ex: "localhost").
    #
    # * *address* - IP address or network name
    def initialize(address : String)
      @m_address = uninitialized UInt32
      VoidCSFML.ipaddress_initialize_zkC(to_unsafe, address.bytesize, address)
    end
    # Construct the address from a string
    #
    # Here *address* can be either a decimal address
    # (ex: "192.168.1.56") or a network name (ex: "localhost").
    # This is equivalent to the constructor taking a std::string
    # parameter, it is defined for convenience so that the
    # implicit conversions from literal strings to IpAddress work.
    #
    # * *address* - IP address or network name
    def initialize(address : UInt8*)
      @m_address = uninitialized UInt32
      VoidCSFML.ipaddress_initialize_Yy6(to_unsafe, address)
    end
    # Construct the address from 4 bytes
    #
    # Calling IpAddress(a, b, c, d) is equivalent to calling
    # IpAddress("a.b.c.d"), but safer as it doesn't have to
    # parse a string to get the address components.
    #
    # * *byte0* - First byte of the address
    # * *byte1* - Second byte of the address
    # * *byte2* - Third byte of the address
    # * *byte3* - Fourth byte of the address
    def initialize(byte0 : Int, byte1 : Int, byte2 : Int, byte3 : Int)
      @m_address = uninitialized UInt32
      VoidCSFML.ipaddress_initialize_9yU9yU9yU9yU(to_unsafe, UInt8.new(byte0), UInt8.new(byte1), UInt8.new(byte2), UInt8.new(byte3))
    end
    # Construct the address from a 32-bits integer
    #
    # This constructor uses the internal representation of
    # the address directly. It should be used for optimization
    # purposes, and only if you got that representation from
    # IpAddress::ToInteger().
    #
    # * *address* - 4 bytes of the address packed into a 32-bits integer
    #
    # *See also:* toInteger
    def initialize(address : Int)
      @m_address = uninitialized UInt32
      VoidCSFML.ipaddress_initialize_saL(to_unsafe, UInt32.new(address))
    end
    # Get a string representation of the address
    #
    # The returned string is the decimal representation of the
    # IP address (like "192.168.1.56"), even if it was constructed
    # from a host name.
    #
    # *Returns:* String representation of the address
    #
    # *See also:* toInteger
    def to_s() : String
      VoidCSFML.ipaddress_tostring(to_unsafe, out result)
      return String.new(result)
    end
    # Get an integer representation of the address
    #
    # The returned number is the internal representation of the
    # address, and should be used for optimization purposes only
    # (like sending the address through a socket).
    # The integer produced by this function can then be converted
    # back to a `SF::IpAddress` with the proper constructor.
    #
    # *Returns:* 32-bits unsigned integer representation of the address
    #
    # *See also:* toString
    def to_integer() : UInt32
      VoidCSFML.ipaddress_tointeger(to_unsafe, out result)
      return result
    end
    # Get the computer's local address
    #
    # The local address is the address of the computer from the
    # LAN point of view, i.e. something like 192.168.1.56. It is
    # meaningful only for communications over the local network.
    # Unlike getPublicAddress, this function is fast and may be
    # used safely anywhere.
    #
    # *Returns:* Local IP address of the computer
    #
    # *See also:* getPublicAddress
    def self.local_address() : IpAddress
      result = IpAddress.allocate
      VoidCSFML.ipaddress_getlocaladdress(result)
      return result
    end
    # Get the computer's public address
    #
    # The public address is the address of the computer from the
    # internet point of view, i.e. something like 89.54.1.169.
    # It is necessary for communications over the world wide web.
    # The only way to get a public address is to ask it to a
    # distant website; as a consequence, this function depends on
    # both your network connection and the server, and may be
    # very slow. You should use it as few as possible. Because
    # this function depends on the network connection and on a distant
    # server, you may use a time limit if you don't want your program
    # to be possibly stuck waiting in case there is a problem; this
    # limit is deactivated by default.
    #
    # * *timeout* - Maximum time to wait
    #
    # *Returns:* Public IP address of the computer
    #
    # *See also:* getLocalAddress
    def self.get_public_address(timeout : Time = Time::Zero) : IpAddress
      result = IpAddress.allocate
      VoidCSFML.ipaddress_getpublicaddress_f4T(timeout, result)
      return result
    end
    @m_address : UInt32
    # Overload of == operator to compare two IP addresses
    #
    # * *left* -  Left operand (a IP address)
    # * *right* - Right operand (a IP address)
    #
    # *Returns:* True if both addresses are equal
    def ==(right : IpAddress) : Bool
      VoidCSFML.operator_eq_BfEBfE(to_unsafe, right, out result)
      return result
    end
    # Overload of != operator to compare two IP addresses
    #
    # * *left* -  Left operand (a IP address)
    # * *right* - Right operand (a IP address)
    #
    # *Returns:* True if both addresses are different
    def !=(right : IpAddress) : Bool
      VoidCSFML.operator_ne_BfEBfE(to_unsafe, right, out result)
      return result
    end
    # Overload of &lt; operator to compare two IP addresses
    #
    # * *left* -  Left operand (a IP address)
    # * *right* - Right operand (a IP address)
    #
    # *Returns:* True if *left* is lesser than *right*
    def <(right : IpAddress) : Bool
      VoidCSFML.operator_lt_BfEBfE(to_unsafe, right, out result)
      return result
    end
    # Overload of &gt; operator to compare two IP addresses
    #
    # * *left* -  Left operand (a IP address)
    # * *right* - Right operand (a IP address)
    #
    # *Returns:* True if *left* is greater than *right*
    def >(right : IpAddress) : Bool
      VoidCSFML.operator_gt_BfEBfE(to_unsafe, right, out result)
      return result
    end
    # Overload of &lt;= operator to compare two IP addresses
    #
    # * *left* -  Left operand (a IP address)
    # * *right* - Right operand (a IP address)
    #
    # *Returns:* True if *left* is lesser or equal than *right*
    def <=(right : IpAddress) : Bool
      VoidCSFML.operator_le_BfEBfE(to_unsafe, right, out result)
      return result
    end
    # Overload of &gt;= operator to compare two IP addresses
    #
    # * *left* -  Left operand (a IP address)
    # * *right* - Right operand (a IP address)
    #
    # *Returns:* True if *left* is greater or equal than *right*
    def >=(right : IpAddress) : Bool
      VoidCSFML.operator_ge_BfEBfE(to_unsafe, right, out result)
      return result
    end
    # :nodoc:
    def to_unsafe()
      pointerof(@m_address).as(Void*)
    end
    # :nodoc:
    def initialize(copy : IpAddress)
      @m_address = uninitialized UInt32
      as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
      VoidCSFML.ipaddress_initialize_BfE(to_unsafe, copy)
    end
    def dup() : self
      return typeof(self).new(self)
    end
  end
  # A HTTP client
  #
  #
  #
  # `SF::Http` is a very simple HTTP client that allows you
  # to communicate with a web server. You can retrieve
  # web pages, send data to an interactive resource,
  # download a remote file, etc. The HTTPS protocol is
  # not supported.
  #
  # The HTTP client is split into 3 classes:
  # * `SF::Http::Request`
  # * `SF::Http::Response`
  # * `SF::Http`
  #
  # `SF::Http::Request` builds the request that will be
  # sent to the server. A request is made of:
  # * a method (what you want to do)
  # * a target URI (usually the name of the web page or file)
  # * one or more header fields (options that you can pass to the server)
  # * an optional body (for POST requests)
  #
  # `SF::Http::Response` parse the response from the web server
  # and provides getters to read them. The response contains:
  # * a status code
  # * header fields (that may be answers to the ones that you requested)
  # * a body, which contains the contents of the requested resource
  #
  # `SF::Http` provides a simple function, SendRequest, to send a
  # `SF::Http::Request` and return the corresponding `SF::Http::Response`
  # from the server.
  #
  # Usage example:
  # ```c++
  # // Create a new HTTP client
  # sf::Http http;
  #
  # // We'll work on http://www.sfml-dev.org
  # http.setHost("http://www.sfml-dev.org");
  #
  # // Prepare a request to get the 'features.php' page
  # sf::Http::Request request("features.php");
  #
  # // Send the request
  # sf::Http::Response response = http.sendRequest(request);
  #
  # // Check the status code and display the result
  # sf::Http::Response::Status status = response.getStatus();
  # if (status == sf::Http::Response::Ok)
  # {
  #     std::cout << response.getBody() << std::endl;
  # }
  # else
  # {
  #     std::cout << "Error " << status << std::endl;
  # }
  # ```
  class Http
    @_http : VoidCSFML::Http_Buffer = VoidCSFML::Http_Buffer.new(0u8)
    # Define a HTTP request
    class Request
      @_http_request : VoidCSFML::Http_Request_Buffer = VoidCSFML::Http_Request_Buffer.new(0u8)
      # Enumerate the available HTTP methods for a request
      enum Method
        # Request in get mode, standard method to retrieve a page
        Get
        # Request in post mode, usually to send data to a page
        Post
        # Request a page's header only
        Head
        # Request in put mode, useful for a REST API
        Put
        # Request in delete mode, useful for a REST API
        Delete
      end
      _sf_enum Http::Request::Method
      # Default constructor
      #
      # This constructor creates a GET request, with the root
      # URI ("/") and an empty body.
      #
      # * *uri* -    Target URI
      # * *method* - Method to use for the request
      # * *body* -   Content of the request's body
      def initialize(uri : String = "/", method : Http::Request::Method = Get, body : String = "")
        @_http_request = uninitialized VoidCSFML::Http_Request_Buffer
        VoidCSFML.http_request_initialize_zkC1ctzkC(to_unsafe, uri.bytesize, uri, method, body.bytesize, body)
      end
      # Set the value of a field
      #
      # The field is created if it doesn't exist. The name of
      # the field is case-insensitive.
      # By default, a request doesn't contain any field (but the
      # mandatory fields are added later by the HTTP client when
      # sending the request).
      #
      # * *field* - Name of the field to set
      # * *value* - Value of the field
      def set_field(field : String, value : String)
        VoidCSFML.http_request_setfield_zkCzkC(to_unsafe, field.bytesize, field, value.bytesize, value)
      end
      # Set the request method
      #
      # See the Method enumeration for a complete list of all
      # the availale methods.
      # The method is Http::Request::Get by default.
      #
      # * *method* - Method to use for the request
      def method=(method : Http::Request::Method)
        VoidCSFML.http_request_setmethod_1ct(to_unsafe, method)
      end
      # Set the requested URI
      #
      # The URI is the resource (usually a web page or a file)
      # that you want to get or post.
      # The URI is "/" (the root page) by default.
      #
      # * *uri* - URI to request, relative to the host
      def uri=(uri : String)
        VoidCSFML.http_request_seturi_zkC(to_unsafe, uri.bytesize, uri)
      end
      # Set the HTTP version for the request
      #
      # The HTTP version is 1.0 by default.
      #
      # * *major* - Major HTTP version number
      # * *minor* - Minor HTTP version number
      def set_http_version(major : Int, minor : Int)
        VoidCSFML.http_request_sethttpversion_emSemS(to_unsafe, LibC::UInt.new(major), LibC::UInt.new(minor))
      end
      # Set the body of the request
      #
      # The body of a request is optional and only makes sense
      # for POST requests. It is ignored for all other methods.
      # The body is empty by default.
      #
      # * *body* - Content of the body
      def body=(body : String)
        VoidCSFML.http_request_setbody_zkC(to_unsafe, body.bytesize, body)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@_http_request).as(Void*)
      end
      # :nodoc:
      def inspect(io)
        to_s(io)
      end
      # :nodoc:
      def initialize(copy : Http::Request)
        @_http_request = uninitialized VoidCSFML::Http_Request_Buffer
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.http_request_initialize_Jat(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Define a HTTP response
    class Response
      @_http_response : VoidCSFML::Http_Response_Buffer = VoidCSFML::Http_Response_Buffer.new(0u8)
      # Enumerate all the valid status codes for a response
      enum Status
        # Most common code returned when operation was successful
        Ok = 200
        # The resource has successfully been created
        Created = 201
        # The request has been accepted, but will be processed later by the server
        Accepted = 202
        # The server didn't send any data in return
        NoContent = 204
        # The server informs the client that it should clear the view (form) that caused the request to be sent
        ResetContent = 205
        # The server has sent a part of the resource, as a response to a partial GET request
        PartialContent = 206
        # The requested page can be accessed from several locations
        MultipleChoices = 300
        # The requested page has permanently moved to a new location
        MovedPermanently = 301
        # The requested page has temporarily moved to a new location
        MovedTemporarily = 302
        # For conditional requests, means the requested page hasn't changed and doesn't need to be refreshed
        NotModified = 304
        # The server couldn't understand the request (syntax error)
        BadRequest = 400
        # The requested page needs an authentication to be accessed
        Unauthorized = 401
        # The requested page cannot be accessed at all, even with authentication
        Forbidden = 403
        # The requested page doesn't exist
        NotFound = 404
        # The server can't satisfy the partial GET request (with a "Range" header field)
        RangeNotSatisfiable = 407
        # The server encountered an unexpected error
        InternalServerError = 500
        # The server doesn't implement a requested feature
        NotImplemented = 501
        # The gateway server has received an error from the source server
        BadGateway = 502
        # The server is temporarily unavailable (overloaded, in maintenance, ...)
        ServiceNotAvailable = 503
        # The gateway server couldn't receive a response from the source server
        GatewayTimeout = 504
        # The server doesn't support the requested HTTP version
        VersionNotSupported = 505
        # Response is not a valid HTTP one
        InvalidResponse = 1000
        # Connection with server failed
        ConnectionFailed = 1001
      end
      _sf_enum Http::Response::Status
      # Default constructor
      #
      # Constructs an empty response.
      def initialize()
        @_http_response = uninitialized VoidCSFML::Http_Response_Buffer
        VoidCSFML.http_response_initialize(to_unsafe)
      end
      # Get the value of a field
      #
      # If the field *field* is not found in the response header,
      # the empty string is returned. This function uses
      # case-insensitive comparisons.
      #
      # * *field* - Name of the field to get
      #
      # *Returns:* Value of the field, or empty string if not found
      def get_field(field : String) : String
        VoidCSFML.http_response_getfield_zkC(to_unsafe, field.bytesize, field, out result)
        return String.new(result)
      end
      # Get the response status code
      #
      # The status code should be the first thing to be checked
      # after receiving a response, it defines whether it is a
      # success, a failure or anything else (see the Status
      # enumeration).
      #
      # *Returns:* Status code of the response
      def status() : Http::Response::Status
        VoidCSFML.http_response_getstatus(to_unsafe, out result)
        return Http::Response::Status.new(result)
      end
      # Get the major HTTP version number of the response
      #
      # *Returns:* Major HTTP version number
      #
      # *See also:* getMinorHttpVersion
      def major_http_version() : UInt32
        VoidCSFML.http_response_getmajorhttpversion(to_unsafe, out result)
        return result
      end
      # Get the minor HTTP version number of the response
      #
      # *Returns:* Minor HTTP version number
      #
      # *See also:* getMajorHttpVersion
      def minor_http_version() : UInt32
        VoidCSFML.http_response_getminorhttpversion(to_unsafe, out result)
        return result
      end
      # Get the body of the response
      #
      # The body of a response may contain:
      # * the requested page (for GET requests)
      # * a response from the server (for POST requests)
      # * nothing (for HEAD requests)
      # * an error message (in case of an error)
      #
      # *Returns:* The response body
      def body() : String
        VoidCSFML.http_response_getbody(to_unsafe, out result)
        return String.new(result)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@_http_response).as(Void*)
      end
      # :nodoc:
      def inspect(io)
        to_s(io)
      end
      # :nodoc:
      def initialize(copy : Http::Response)
        @_http_response = uninitialized VoidCSFML::Http_Response_Buffer
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.http_response_initialize_N50(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Default constructor
    def initialize()
      @_http = uninitialized VoidCSFML::Http_Buffer
      VoidCSFML.http_initialize(to_unsafe)
    end
    # Construct the HTTP client with the target host
    #
    # This is equivalent to calling setHost(host, port).
    # The port has a default value of 0, which means that the
    # HTTP client will use the right port according to the
    # protocol used (80 for HTTP). You should leave it like
    # this unless you really need a port other than the
    # standard one, or use an unknown protocol.
    #
    # * *host* - Web server to connect to
    # * *port* - Port to use for connection
    def initialize(host : String, port : Int = 0)
      @_http = uninitialized VoidCSFML::Http_Buffer
      VoidCSFML.http_initialize_zkCbxi(to_unsafe, host.bytesize, host, LibC::UShort.new(port))
    end
    # Set the target host
    #
    # This function just stores the host address and port, it
    # doesn't actually connect to it until you send a request.
    # The port has a default value of 0, which means that the
    # HTTP client will use the right port according to the
    # protocol used (80 for HTTP). You should leave it like
    # this unless you really need a port other than the
    # standard one, or use an unknown protocol.
    #
    # * *host* - Web server to connect to
    # * *port* - Port to use for connection
    def set_host(host : String, port : Int = 0)
      VoidCSFML.http_sethost_zkCbxi(to_unsafe, host.bytesize, host, LibC::UShort.new(port))
    end
    # Send a HTTP request and return the server's response.
    #
    # You must have a valid host before sending a request (see setHost).
    # Any missing mandatory header field in the request will be added
    # with an appropriate value.
    # Warning: this function waits for the server's response and may
    # not return instantly; use a thread if you don't want to block your
    # application, or use a timeout to limit the time to wait. A value
    # of Time::Zero means that the client will use the system default timeout
    # (which is usually pretty long).
    #
    # * *request* - Request to send
    # * *timeout* - Maximum time to wait
    #
    # *Returns:* Server's response
    def send_request(request : Http::Request, timeout : Time = Time::Zero) : Http::Response
      result = Http::Response.allocate
      VoidCSFML.http_sendrequest_Jatf4T(to_unsafe, request, timeout, result)
      return result
    end
    include NonCopyable
    # :nodoc:
    def to_unsafe()
      pointerof(@_http).as(Void*)
    end
    # :nodoc:
    def inspect(io)
      to_s(io)
    end
  end
  # Utility class to build blocks of data to transfer
  #        over the network
  #
  #
  #
  # Packets provide a safe and easy way to serialize data,
  # in order to send it over the network using sockets
  # (`SF::TcpSocket`, `SF::UdpSocket`).
  #
  # Packets solve 2 fundamental problems that arise when
  # transferring data over the network:
  # * data is interpreted correctly according to the endianness
  # * the bounds of the packet are preserved (one send == one receive)
  #
  # The `SF::Packet` class provides both input and output modes.
  # It is designed to follow the behavior of standard C++ streams,
  # using operators &gt;&gt; and &lt;&lt; to extract and insert data.
  #
  # It is recommended to use only fixed-size types (like `SF::Int32`, etc.),
  # to avoid possible differences between the sender and the receiver.
  # Indeed, the native C++ types may have different sizes on two platforms
  # and your data may be corrupted if that happens.
  #
  # Usage example:
  # ```c++
  # sf::Uint32 x = 24;
  # std::string s = "hello";
  # double d = 5.89;
  #
  # // Group the variables to send into a packet
  # sf::Packet packet;
  # packet << x << s << d;
  #
  # // Send it over the network (socket is a valid sf::TcpSocket)
  # socket.send(packet);
  #
  # -----------------------------------------------------------------
  #
  # // Receive the packet at the other end
  # sf::Packet packet;
  # socket.receive(packet);
  #
  # // Extract the variables contained in the packet
  # sf::Uint32 x;
  # std::string s;
  # double d;
  # if (packet >> x >> s >> d)
  # {
  #     // Data extracted successfully...
  # }
  # ```
  #
  # Packets have built-in operator &gt;&gt; and &lt;&lt; overloads for
  # standard types:
  # * bool
  # * fixed-size integer types (`SF::Int8/16/32`, `SF::Uint8/16/32`)
  # * floating point numbers (float, double)
  # * string types (char*, wchar_t*, std::string, std::wstring, `SF::String`)
  #
  # Like standard streams, it is also possible to define your own
  # overloads of operators &gt;&gt; and &lt;&lt; in order to handle your
  # custom types.
  #
  # ```c++
  # struct MyStruct
  # {
  #     float       number;
  #     sf::Int8    integer;
  #     std::string str;
  # };
  #
  # sf::Packet& operator <<(sf::Packet& packet, const MyStruct& m)
  # {
  #     return packet << m.number << m.integer << m.str;
  # }
  #
  # sf::Packet& operator >>(sf::Packet& packet, MyStruct& m)
  # {
  #     return packet >> m.number >> m.integer >> m.str;
  # }
  # ```
  #
  # Packets also provide an extra feature that allows to apply
  # custom transformations to the data before it is sent,
  # and after it is received. This is typically used to
  # handle automatic compression or encryption of the data.
  # This is achieved by inheriting from `SF::Packet`, and overriding
  # the onSend and onReceive functions.
  #
  # Here is an example:
  # ```c++
  # class ZipPacket : public sf::Packet
  # {
  #     virtual const void* onSend(std::size_t& size)
  #     {
  #         const void* srcData = getData();
  #         std::size_t srcSize = getDataSize();
  #
  #         return MySuperZipFunction(srcData, srcSize, &size);
  #     }
  #
  #     virtual void onReceive(const void* data, std::size_t size)
  #     {
  #         std::size_t dstSize;
  #         const void* dstData = MySuperUnzipFunction(data, size, &dstSize);
  #
  #         append(dstData, dstSize);
  #     }
  # };
  #
  # // Use like regular packets:
  # ZipPacket packet;
  # packet << x << s << d;
  # ...
  # ```
  #
  # *See also:* `SF::TcpSocket`, `SF::UdpSocket`
  class Packet
    @_packet : VoidCSFML::Packet_Buffer = VoidCSFML::Packet_Buffer.new(0u8)
    # Default constructor
    #
    # Creates an empty packet.
    def initialize()
      @_packet = uninitialized VoidCSFML::Packet_Buffer
      VoidCSFML.packet_initialize(to_unsafe)
    end
    # Virtual destructor
    def finalize()
      VoidCSFML.packet_finalize(to_unsafe)
    end
    # Append data to the end of the packet
    #
    # * *data* -        Pointer to the sequence of bytes to append
    # * *size_in_bytes* - Number of bytes to append
    #
    # *See also:* clear
    def append(data : Slice)
      VoidCSFML.packet_append_5h8vgv(to_unsafe, data, data.bytesize)
    end
    # Clear the packet
    #
    # After calling Clear, the packet is empty.
    #
    # *See also:* append
    def clear()
      VoidCSFML.packet_clear(to_unsafe)
    end
    # Get a pointer to the data contained in the packet
    #
    # Warning: the returned pointer may become invalid after
    # you append data to the packet, therefore it should never
    # be stored.
    # The return pointer is NULL if the packet is empty.
    #
    # *Returns:* Pointer to the data
    #
    # *See also:* getDataSize
    def data() : Void*
      VoidCSFML.packet_getdata(to_unsafe, out result)
      return result
    end
    # Get the size of the data contained in the packet
    #
    # This function returns the number of bytes pointed to by
    # what getData returns.
    #
    # *Returns:* Data size, in bytes
    #
    # *See also:* getData
    def data_size() : LibC::SizeT
      VoidCSFML.packet_getdatasize(to_unsafe, out result)
      return result
    end
    # Tell if the reading position has reached the
    #        end of the packet
    #
    # This function is useful to know if there is some data
    # left to be read, without actually reading it.
    #
    # *Returns:* True if all data was read, false otherwise
    #
    # *See also:* operator bool
    def end_of_packet() : Bool
      VoidCSFML.packet_endofpacket(to_unsafe, out result)
      return result
    end
    # Test the validity of the packet, for reading
    #
    # This operator allows to test the packet as a boolean
    # variable, to check if a reading operation was successful.
    #
    # A packet will be in an invalid state if it has no more
    # data to read.
    #
    # This behavior is the same as standard C++ streams.
    #
    # Usage example:
    # ```c++
    # float x;
    # packet >> x;
    # if (packet)
    # {
    #    // ok, x was extracted successfully
    # }
    #
    # // -- or --
    #
    # float x;
    # if (packet >> x)
    # {
    #    // ok, x was extracted successfully
    # }
    # ```
    #
    # Don't focus on the return type, it's equivalent to bool but
    # it disallows unwanted implicit conversions to integer or
    # pointer types.
    #
    # *Returns:* True if last data extraction from packet was successful
    #
    # *See also:* endOfPacket
    def valid?() : Bool
      VoidCSFML.packet_operator_bool(to_unsafe, out result)
      return result
    end
    # Overloads of operator &gt;&gt; to read data from the packet
    def read(type : Bool.class) : Bool
      VoidCSFML.packet_operator_shr_gRY(to_unsafe, out data)
      return data
    end
    def read(type : Int8.class) : Int8
      VoidCSFML.packet_operator_shr_y9(to_unsafe, out data)
      return data
    end
    def read(type : UInt8.class) : UInt8
      VoidCSFML.packet_operator_shr_8hc(to_unsafe, out data)
      return data
    end
    def read(type : Int16.class) : Int16
      VoidCSFML.packet_operator_shr_4k3(to_unsafe, out data)
      return data
    end
    def read(type : UInt16.class) : UInt16
      VoidCSFML.packet_operator_shr_Xag(to_unsafe, out data)
      return data
    end
    def read(type : Int32.class) : Int32
      VoidCSFML.packet_operator_shr_NiZ(to_unsafe, out data)
      return data
    end
    def read(type : UInt32.class) : UInt32
      VoidCSFML.packet_operator_shr_qTz(to_unsafe, out data)
      return data
    end
    def read(type : Int64.class) : Int64
      VoidCSFML.packet_operator_shr_BuW(to_unsafe, out data)
      return data
    end
    def read(type : UInt64.class) : UInt64
      VoidCSFML.packet_operator_shr_7H7(to_unsafe, out data)
      return data
    end
    def read(type : Float32.class) : Float32
      VoidCSFML.packet_operator_shr_ATF(to_unsafe, out data)
      return data
    end
    def read(type : Float64.class) : Float64
      VoidCSFML.packet_operator_shr_nIp(to_unsafe, out data)
      return data
    end
    def read(type : String.class) : String
      VoidCSFML.packet_operator_shr_GHF(to_unsafe, out data)
      return String.new(data)
    end
    # Overloads of operator &lt;&lt; to write data into the packet
    def write(data : Bool)
      VoidCSFML.packet_operator_shl_GZq(to_unsafe, data)
      self
    end
    def write(data : Int8)
      VoidCSFML.packet_operator_shl_k6g(to_unsafe, data)
      self
    end
    def write(data : UInt8)
      VoidCSFML.packet_operator_shl_9yU(to_unsafe, data)
      self
    end
    def write(data : Int16)
      VoidCSFML.packet_operator_shl_yAA(to_unsafe, data)
      self
    end
    def write(data : UInt16)
      VoidCSFML.packet_operator_shl_BtU(to_unsafe, data)
      self
    end
    def write(data : Int32)
      VoidCSFML.packet_operator_shl_qe2(to_unsafe, data)
      self
    end
    def write(data : UInt32)
      VoidCSFML.packet_operator_shl_saL(to_unsafe, data)
      self
    end
    def write(data : Int64)
      VoidCSFML.packet_operator_shl_G4x(to_unsafe, data)
      self
    end
    def write(data : UInt64)
      VoidCSFML.packet_operator_shl_Jvt(to_unsafe, data)
      self
    end
    def write(data : Float32)
      VoidCSFML.packet_operator_shl_Bw9(to_unsafe, data)
      self
    end
    def write(data : Float64)
      VoidCSFML.packet_operator_shl_mYt(to_unsafe, data)
      self
    end
    def write(data : String)
      VoidCSFML.packet_operator_shl_zkC(to_unsafe, data.bytesize, data)
      self
    end
    # :nodoc:
    def to_unsafe()
      pointerof(@_packet).as(Void*)
    end
    # :nodoc:
    def inspect(io)
      to_s(io)
    end
    # :nodoc:
    def initialize(copy : Packet)
      @_packet = uninitialized VoidCSFML::Packet_Buffer
      as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
      VoidCSFML.packet_initialize_54U(to_unsafe, copy)
    end
    def dup() : self
      return typeof(self).new(self)
    end
  end
  # Multiplexer that allows to read from multiple sockets
  #
  #
  #
  # Socket selectors provide a way to wait until some data is
  # available on a set of sockets, instead of just one. This
  # is convenient when you have multiple sockets that may
  # possibly receive data, but you don't know which one will
  # be ready first. In particular, it avoids to use a thread
  # for each socket; with selectors, a single thread can handle
  # all the sockets.
  #
  # All types of sockets can be used in a selector:
  # * `SF::TcpListener`
  # * `SF::TcpSocket`
  # * `SF::UdpSocket`
  #
  # A selector doesn't store its own copies of the sockets
  # (socket classes are not copyable anyway), it simply keeps
  # a reference to the original sockets that you pass to the
  # "add" function. Therefore, you can't use the selector as a
  # socket container, you must store them outside and make sure
  # that they are alive as long as they are used in the selector.
  #
  # Using a selector is simple:
  # * populate the selector with all the sockets that you want to observe
  # * make it wait until there is data available on any of the sockets
  # * test each socket to find out which ones are ready
  #
  # Usage example:
  # ```c++
  # // Create a socket to listen to new connections
  # sf::TcpListener listener;
  # listener.listen(55001);
  #
  # // Create a list to store the future clients
  # std::list<sf::TcpSocket*> clients;
  #
  # // Create a selector
  # sf::SocketSelector selector;
  #
  # // Add the listener to the selector
  # selector.add(listener);
  #
  # // Endless loop that waits for new connections
  # while (running)
  # {
  #     // Make the selector wait for data on any socket
  #     if (selector.wait())
  #     {
  #         // Test the listener
  #         if (selector.isReady(listener))
  #         {
  #             // The listener is ready: there is a pending connection
  #             sf::TcpSocket* client = new sf::TcpSocket;
  #             if (listener.accept(*client) == sf::Socket::Done)
  #             {
  #                 // Add the new client to the clients list
  #                 clients.push_back(client);
  #
  #                 // Add the new client to the selector so that we will
  #                 // be notified when he sends something
  #                 selector.add(*client);
  #             }
  #             else
  #             {
  #                 // Error, we won't get a new connection, delete the socket
  #                 delete client;
  #             }
  #         }
  #         else
  #         {
  #             // The listener socket is not ready, test all other sockets (the clients)
  #             for (std::list<sf::TcpSocket*>::iterator it = clients.begin(); it != clients.end(); ++it)
  #             {
  #                 sf::TcpSocket& client = **it;
  #                 if (selector.isReady(client))
  #                 {
  #                     // The client has sent some data, we can receive it
  #                     sf::Packet packet;
  #                     if (client.receive(packet) == sf::Socket::Done)
  #                     {
  #                         ...
  #                     }
  #                 }
  #             }
  #         }
  #     }
  # }
  # ```
  #
  # *See also:* `SF::Socket`
  class SocketSelector
    @_socketselector : VoidCSFML::SocketSelector_Buffer = VoidCSFML::SocketSelector_Buffer.new(0u8)
    # Default constructor
    def initialize()
      @_socketselector = uninitialized VoidCSFML::SocketSelector_Buffer
      VoidCSFML.socketselector_initialize(to_unsafe)
    end
    # Destructor
    def finalize()
      VoidCSFML.socketselector_finalize(to_unsafe)
    end
    # Add a new socket to the selector
    #
    # This function keeps a weak reference to the socket,
    # so you have to make sure that the socket is not destroyed
    # while it is stored in the selector.
    # This function does nothing if the socket is not valid.
    #
    # * *socket* - Reference to the socket to add
    #
    # *See also:* remove, clear
    def add(socket : Socket)
      VoidCSFML.socketselector_add_JTp(to_unsafe, socket)
    end
    # Remove a socket from the selector
    #
    # This function doesn't destroy the socket, it simply
    # removes the reference that the selector has to it.
    #
    # * *socket* - Reference to the socket to remove
    #
    # *See also:* add, clear
    def remove(socket : Socket)
      VoidCSFML.socketselector_remove_JTp(to_unsafe, socket)
    end
    # Remove all the sockets stored in the selector
    #
    # This function doesn't destroy any instance, it simply
    # removes all the references that the selector has to
    # external sockets.
    #
    # *See also:* add, remove
    def clear()
      VoidCSFML.socketselector_clear(to_unsafe)
    end
    # Wait until one or more sockets are ready to receive
    #
    # This function returns as soon as at least one socket has
    # some data available to be received. To know which sockets are
    # ready, use the isReady function.
    # If you use a timeout and no socket is ready before the timeout
    # is over, the function returns false.
    #
    # * *timeout* - Maximum time to wait, (use Time::Zero for infinity)
    #
    # *Returns:* True if there are sockets ready, false otherwise
    #
    # *See also:* isReady
    def wait(timeout : Time = Time::Zero) : Bool
      VoidCSFML.socketselector_wait_f4T(to_unsafe, timeout, out result)
      return result
    end
    # Test a socket to know if it is ready to receive data
    #
    # This function must be used after a call to Wait, to know
    # which sockets are ready to receive data. If a socket is
    # ready, a call to receive will never block because we know
    # that there is data available to read.
    # Note that if this function returns true for a TcpListener,
    # this means that it is ready to accept a new connection.
    #
    # * *socket* - Socket to test
    #
    # *Returns:* True if the socket is ready to read, false otherwise
    #
    # *See also:* isReady
    def ready?(socket : Socket) : Bool
      VoidCSFML.socketselector_isready_JTp(to_unsafe, socket, out result)
      return result
    end
    # :nodoc:
    def to_unsafe()
      pointerof(@_socketselector).as(Void*)
    end
    # :nodoc:
    def inspect(io)
      to_s(io)
    end
    # :nodoc:
    def initialize(copy : SocketSelector)
      @_socketselector = uninitialized VoidCSFML::SocketSelector_Buffer
      as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
      VoidCSFML.socketselector_initialize_fWq(to_unsafe, copy)
    end
    def dup() : self
      return typeof(self).new(self)
    end
  end
  # Socket that listens to new TCP connections
  #
  #
  #
  # A listener socket is a special type of socket that listens to
  # a given port and waits for connections on that port.
  # This is all it can do.
  #
  # When a new connection is received, you must call accept and
  # the listener returns a new instance of `SF::TcpSocket` that
  # is properly initialized and can be used to communicate with
  # the new client.
  #
  # Listener sockets are specific to the TCP protocol,
  # UDP sockets are connectionless and can therefore communicate
  # directly. As a consequence, a listener socket will always
  # return the new connections as `SF::TcpSocket` instances.
  #
  # A listener is automatically closed on destruction, like all
  # other types of socket. However if you want to stop listening
  # before the socket is destroyed, you can call its close()
  # function.
  #
  # Usage example:
  # ```c++
  # // Create a listener socket and make it wait for new
  # // connections on port 55001
  # sf::TcpListener listener;
  # listener.listen(55001);
  #
  # // Endless loop that waits for new connections
  # while (running)
  # {
  #     sf::TcpSocket client;
  #     if (listener.accept(client) == sf::Socket::Done)
  #     {
  #         // A new client just connected!
  #         std::cout << "New connection received from " << client.getRemoteAddress() << std::endl;
  #         doSomethingWith(client);
  #     }
  # }
  # ```
  #
  # *See also:* `SF::TcpSocket`, `SF::Socket`
  class TcpListener < Socket
    @_tcplistener : VoidCSFML::TcpListener_Buffer = VoidCSFML::TcpListener_Buffer.new(0u8)
    # Default constructor
    def initialize()
      @_socket = uninitialized VoidCSFML::Socket_Buffer
      @_tcplistener = uninitialized VoidCSFML::TcpListener_Buffer
      VoidCSFML.tcplistener_initialize(to_unsafe)
    end
    # Get the port to which the socket is bound locally
    #
    # If the socket is not listening to a port, this function
    # returns 0.
    #
    # *Returns:* Port to which the socket is bound
    #
    # *See also:* listen
    def local_port() : UInt16
      VoidCSFML.tcplistener_getlocalport(to_unsafe, out result)
      return result
    end
    # Start listening for connections
    #
    # This functions makes the socket listen to the specified
    # port, waiting for new connections.
    # If the socket was previously listening to another port,
    # it will be stopped first and bound to the new port.
    #
    # * *port* - Port to listen for new connections
    #
    # *Returns:* Status code
    #
    # *See also:* accept, close
    def listen(port : Int) : Socket::Status
      VoidCSFML.tcplistener_listen_bxi(to_unsafe, LibC::UShort.new(port), out result)
      return Socket::Status.new(result)
    end
    # Stop listening and close the socket
    #
    # This function gracefully stops the listener. If the
    # socket is not listening, this function has no effect.
    #
    # *See also:* listen
    def close()
      VoidCSFML.tcplistener_close(to_unsafe)
    end
    # Accept a new connection
    #
    # If the socket is in blocking mode, this function will
    # not return until a connection is actually received.
    #
    # * *socket* - Socket that will hold the new connection
    #
    # *Returns:* Status code
    #
    # *See also:* listen
    def accept(socket : TcpSocket) : Socket::Status
      VoidCSFML.tcplistener_accept_WsF(to_unsafe, socket, out result)
      return Socket::Status.new(result)
    end
    # :nodoc:
    def blocking=(blocking : Bool)
      VoidCSFML.tcplistener_setblocking_GZq(to_unsafe, blocking)
    end
    # :nodoc:
    def blocking?() : Bool
      VoidCSFML.tcplistener_isblocking(to_unsafe, out result)
      return result
    end
    # :nodoc:
    def to_unsafe()
      pointerof(@_socket).as(Void*)
    end
    # :nodoc:
    def inspect(io)
      to_s(io)
    end
  end
  # Specialized socket using the UDP protocol
  #
  #
  #
  # A UDP socket is a connectionless socket. Instead of
  # connecting once to a remote host, like TCP sockets,
  # it can send to and receive from any host at any time.
  #
  # It is a datagram protocol: bounded blocks of data (datagrams)
  # are transfered over the network rather than a continuous
  # stream of data (TCP). Therefore, one call to send will always
  # match one call to receive (if the datagram is not lost),
  # with the same data that was sent.
  #
  # The UDP protocol is lightweight but unreliable. Unreliable
  # means that datagrams may be duplicated, be lost or
  # arrive reordered. However, if a datagram arrives, its
  # data is guaranteed to be valid.
  #
  # UDP is generally used for real-time communication
  # (audio or video streaming, real-time games, etc.) where
  # speed is crucial and lost data doesn't matter much.
  #
  # Sending and receiving data can use either the low-level
  # or the high-level functions. The low-level functions
  # process a raw sequence of bytes, whereas the high-level
  # interface uses packets (see `SF::Packet`), which are easier
  # to use and provide more safety regarding the data that is
  # exchanged. You can look at the `SF::Packet` class to get
  # more details about how they work.
  #
  # It is important to note that UdpSocket is unable to send
  # datagrams bigger than MaxDatagramSize. In this case, it
  # returns an error and doesn't send anything. This applies
  # to both raw data and packets. Indeed, even packets are
  # unable to split and recompose data, due to the unreliability
  # of the protocol (dropped, mixed or duplicated datagrams may
  # lead to a big mess when trying to recompose a packet).
  #
  # If the socket is bound to a port, it is automatically
  # unbound from it when the socket is destroyed. However,
  # you can unbind the socket explicitly with the Unbind
  # function if necessary, to stop receiving messages or
  # make the port available for other sockets.
  #
  # Usage example:
  # ```c++
  # // ----- The client -----
  #
  # // Create a socket and bind it to the port 55001
  # sf::UdpSocket socket;
  # socket.bind(55001);
  #
  # // Send a message to 192.168.1.50 on port 55002
  # std::string message = "Hi, I am " + sf::IpAddress::getLocalAddress().toString();
  # socket.send(message.c_str(), message.size() + 1, "192.168.1.50", 55002);
  #
  # // Receive an answer (most likely from 192.168.1.50, but could be anyone else)
  # char buffer[1024];
  # std::size_t received = 0;
  # sf::IpAddress sender;
  # unsigned short port;
  # socket.receive(buffer, sizeof(buffer), received, sender, port);
  # std::cout << sender.ToString() << " said: " << buffer << std::endl;
  #
  # // ----- The server -----
  #
  # // Create a socket and bind it to the port 55002
  # sf::UdpSocket socket;
  # socket.bind(55002);
  #
  # // Receive a message from anyone
  # char buffer[1024];
  # std::size_t received = 0;
  # sf::IpAddress sender;
  # unsigned short port;
  # socket.receive(buffer, sizeof(buffer), received, sender, port);
  # std::cout << sender.ToString() << " said: " << buffer << std::endl;
  #
  # // Send an answer
  # std::string message = "Welcome " + sender.toString();
  # socket.send(message.c_str(), message.size() + 1, sender, port);
  # ```
  #
  # *See also:* `SF::Socket`, `SF::TcpSocket`, `SF::Packet`
  class UdpSocket < Socket
    @_udpsocket : VoidCSFML::UdpSocket_Buffer = VoidCSFML::UdpSocket_Buffer.new(0u8)
    # The maximum number of bytes that can be sent in a single UDP datagram
    MaxDatagramSize = 65507
    # Default constructor
    def initialize()
      @_socket = uninitialized VoidCSFML::Socket_Buffer
      @_udpsocket = uninitialized VoidCSFML::UdpSocket_Buffer
      VoidCSFML.udpsocket_initialize(to_unsafe)
    end
    # Get the port to which the socket is bound locally
    #
    # If the socket is not bound to a port, this function
    # returns 0.
    #
    # *Returns:* Port to which the socket is bound
    #
    # *See also:* bind
    def local_port() : UInt16
      VoidCSFML.udpsocket_getlocalport(to_unsafe, out result)
      return result
    end
    # Bind the socket to a specific port
    #
    # Binding the socket to a port is necessary for being
    # able to receive data on that port.
    # You can use the special value Socket::AnyPort to tell the
    # system to automatically pick an available port, and then
    # call getLocalPort to retrieve the chosen port.
    #
    # * *port* - Port to bind the socket to
    #
    # *Returns:* Status code
    #
    # *See also:* unbind, getLocalPort
    def bind(port : Int) : Socket::Status
      VoidCSFML.udpsocket_bind_bxi(to_unsafe, LibC::UShort.new(port), out result)
      return Socket::Status.new(result)
    end
    # Unbind the socket from the local port to which it is bound
    #
    # The port that the socket was previously using is immediately
    # available after this function is called. If the
    # socket is not bound to a port, this function has no effect.
    #
    # *See also:* bind
    def unbind()
      VoidCSFML.udpsocket_unbind(to_unsafe)
    end
    # Send raw data to a remote peer
    #
    # Make sure that *size* is not greater than
    # UdpSocket::MaxDatagramSize, otherwise this function will
    # fail and no data will be sent.
    #
    # * *data* -          Pointer to the sequence of bytes to send
    # * *size* -          Number of bytes to send
    # * *remote_address* - Address of the receiver
    # * *remote_port* -    Port of the receiver to send the data to
    #
    # *Returns:* Status code
    #
    # *See also:* receive
    def send(data : Slice, remote_address : IpAddress, remote_port : Int) : Socket::Status
      VoidCSFML.udpsocket_send_5h8vgvBfEbxi(to_unsafe, data, data.bytesize, remote_address, LibC::UShort.new(remote_port), out result)
      return Socket::Status.new(result)
    end
    # Receive raw data from a remote peer
    #
    # In blocking mode, this function will wait until some
    # bytes are actually received.
    # Be careful to use a buffer which is large enough for
    # the data that you intend to receive, if it is too small
    # then an error will be returned and *all* the data will
    # be lost.
    #
    # * *data* -          Pointer to the array to fill with the received bytes
    # * *size* -          Maximum number of bytes that can be received
    # * *received* -      This variable is filled with the actual number of bytes received
    # * *remote_address* - Address of the peer that sent the data
    # * *remote_port* -    Port of the peer that sent the data
    #
    # *Returns:* Status code
    #
    # *See also:* send
    def receive(data : Slice) : {Socket::Status, LibC::SizeT, IpAddress, UInt16}
      remote_address = IpAddress.new
      VoidCSFML.udpsocket_receive_xALvgvi499ylYII(to_unsafe, data, data.bytesize, out received, remote_address, out remote_port, out result)
      return Socket::Status.new(result), received, remote_address, remote_port
    end
    # Send a formatted packet of data to a remote peer
    #
    # Make sure that the packet size is not greater than
    # UdpSocket::MaxDatagramSize, otherwise this function will
    # fail and no data will be sent.
    #
    # * *packet* -        Packet to send
    # * *remote_address* - Address of the receiver
    # * *remote_port* -    Port of the receiver to send the data to
    #
    # *Returns:* Status code
    #
    # *See also:* receive
    def send(packet : Packet, remote_address : IpAddress, remote_port : Int) : Socket::Status
      VoidCSFML.udpsocket_send_jyFBfEbxi(to_unsafe, packet, remote_address, LibC::UShort.new(remote_port), out result)
      return Socket::Status.new(result)
    end
    # Receive a formatted packet of data from a remote peer
    #
    # In blocking mode, this function will wait until the whole packet
    # has been received.
    #
    # * *packet* -        Packet to fill with the received data
    # * *remote_address* - Address of the peer that sent the data
    # * *remote_port* -    Port of the peer that sent the data
    #
    # *Returns:* Status code
    #
    # *See also:* send
    def receive(packet : Packet) : {Socket::Status, IpAddress, UInt16}
      remote_address = IpAddress.new
      VoidCSFML.udpsocket_receive_jyF9ylYII(to_unsafe, packet, remote_address, out remote_port, out result)
      return Socket::Status.new(result), remote_address, remote_port
    end
    # :nodoc:
    def blocking=(blocking : Bool)
      VoidCSFML.udpsocket_setblocking_GZq(to_unsafe, blocking)
    end
    # :nodoc:
    def blocking?() : Bool
      VoidCSFML.udpsocket_isblocking(to_unsafe, out result)
      return result
    end
    # :nodoc:
    def to_unsafe()
      pointerof(@_socket).as(Void*)
    end
    # :nodoc:
    def inspect(io)
      to_s(io)
    end
  end
  VoidCSFML.sfml_network_version(out major, out minor, out patch)
  if SFML_VERSION != (ver = "#{major}.#{minor}.#{patch}")
    STDERR.puts "Warning: CrSFML was built for SFML #{SFML_VERSION}, found SFML #{ver}"
  end
end
