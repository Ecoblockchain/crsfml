require "./lib"
require "../common"
require "../system"
module SF
  extend self
  # Base class for classes that require an OpenGL context
  #
  #
  #
  # This class is for internal use only, it must be the base
  # of every class that requires a valid OpenGL context in
  # order to work.
  module GlResource
  end
  # Structure defining the settings of the OpenGL
  #        context attached to a window
  #
  #
  #
  # ContextSettings allows to define several advanced settings
  # of the OpenGL context attached to a window. All these
  # settings with the exception of the compatibility flag
  # and anti-aliasing level have no impact on the regular
  # SFML rendering (graphics module), so you may need to use
  # this structure only if you're using SFML as a windowing
  # system for custom OpenGL rendering.
  #
  # The depthBits and stencilBits members define the number
  # of bits per pixel requested for the (respectively) depth
  # and stencil buffers.
  #
  # antialiasingLevel represents the requested number of
  # multisampling levels for anti-aliasing.
  #
  # majorVersion and minorVersion define the version of the
  # OpenGL context that you want. Only versions greater or
  # equal to 3.0 are relevant; versions lesser than 3.0 are
  # all handled the same way (i.e. you can use any version
  # &lt; 3.0 if you don't want an OpenGL 3 context).
  #
  # When requesting a context with a version greater or equal
  # to 3.2, you have the option of specifying whether the
  # context should follow the core or compatibility profile
  # of all newer (&gt;= 3.2) OpenGL specifications. For versions
  # 3.0 and 3.1 there is only the core profile. By default
  # a compatibility context is created. You only need to specify
  # the core flag if you want a core profile context to use with
  # your own OpenGL rendering.
  # **Warning: The graphics module will not function if you
  # request a core profile context. Make sure the attributes are
  # set to Default if you want to use the graphics module.**
  #
  # Setting the debug attribute flag will request a context with
  # additional debugging features enabled. Depending on the
  # system, this might be required for advanced OpenGL debugging.
  # OpenGL debugging is disabled by default.
  #
  # **Special Note for OS X:**
  # Apple only supports choosing between either a legacy context
  # (OpenGL 2.1) or a core context (OpenGL version depends on the
  # operating system version but is at least 3.2). Compatibility
  # contexts are not supported. Further information is available on the
  # &lt;a href="https://developer.apple.com/opengl/capabilities/index.html"&gt;
  # OpenGL Capabilities Tables&lt;/a&gt; page. OS X also currently does
  # not support debug contexts.
  #
  # Please note that these values are only a hint.
  # No failure will be reported if one or more of these values
  # are not supported by the system; instead, SFML will try to
  # find the closest valid match. You can then retrieve the
  # settings that the window actually used to create its context,
  # with Window::getSettings().
  struct ContextSettings
    @depth_bits : LibC::UInt
    @stencil_bits : LibC::UInt
    @antialiasing_level : LibC::UInt
    @major_version : LibC::UInt
    @minor_version : LibC::UInt
    @attribute_flags : UInt32
    # Enumeration of the context attribute flags
    @[Flags]
    enum Attribute
      # Non-debug, compatibility context (this and the core attribute are mutually exclusive)
      Default = 0
      # Core attribute
      Core = 1 << 0
      # Debug attribute
      Debug = 1 << 2
    end
    _sf_enum ContextSettings::Attribute
    # Default constructor
    #
    # * *depth* -        Depth buffer bits
    # * *stencil* -      Stencil buffer bits
    # * *antialiasing* - Antialiasing level
    # * *major* -        Major number of the context version
    # * *minor* -        Minor number of the context version
    # * *attributes* -   Attribute flags of the context
    def initialize(depth : Int = 0, stencil : Int = 0, antialiasing : Int = 0, major : Int = 1, minor : Int = 1, attributes : Int = Default)
      @depth_bits = uninitialized UInt32
      @stencil_bits = uninitialized UInt32
      @antialiasing_level = uninitialized UInt32
      @major_version = uninitialized UInt32
      @minor_version = uninitialized UInt32
      @attribute_flags = uninitialized UInt32
      VoidCSFML.contextsettings_initialize_emSemSemSemSemSemS(to_unsafe, LibC::UInt.new(depth), LibC::UInt.new(stencil), LibC::UInt.new(antialiasing), LibC::UInt.new(major), LibC::UInt.new(minor), LibC::UInt.new(attributes))
    end
    @depth_bits : LibC::UInt
    # Bits of the depth buffer
    def depth_bits : UInt32
      @depth_bits
    end
    def depth_bits=(depth_bits : Int)
      @depth_bits = LibC::UInt.new(depth_bits)
    end
    @stencil_bits : LibC::UInt
    # Bits of the stencil buffer
    def stencil_bits : UInt32
      @stencil_bits
    end
    def stencil_bits=(stencil_bits : Int)
      @stencil_bits = LibC::UInt.new(stencil_bits)
    end
    @antialiasing_level : LibC::UInt
    # Level of antialiasing
    def antialiasing_level : UInt32
      @antialiasing_level
    end
    def antialiasing_level=(antialiasing_level : Int)
      @antialiasing_level = LibC::UInt.new(antialiasing_level)
    end
    @major_version : LibC::UInt
    # Major number of the context version to create
    def major_version : UInt32
      @major_version
    end
    def major_version=(major_version : Int)
      @major_version = LibC::UInt.new(major_version)
    end
    @minor_version : LibC::UInt
    # Minor number of the context version to create
    def minor_version : UInt32
      @minor_version
    end
    def minor_version=(minor_version : Int)
      @minor_version = LibC::UInt.new(minor_version)
    end
    @attribute_flags : UInt32
    # The attribute flags to create the context with
    def attribute_flags : UInt32
      @attribute_flags
    end
    def attribute_flags=(attribute_flags : Int)
      @attribute_flags = UInt32.new(attribute_flags)
    end
    # :nodoc:
    def to_unsafe()
      pointerof(@depth_bits).as(Void*)
    end
    # :nodoc:
    def initialize(copy : ContextSettings)
      @depth_bits = uninitialized UInt32
      @stencil_bits = uninitialized UInt32
      @antialiasing_level = uninitialized UInt32
      @major_version = uninitialized UInt32
      @minor_version = uninitialized UInt32
      @attribute_flags = uninitialized UInt32
      as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
      VoidCSFML.contextsettings_initialize_Fw4(to_unsafe, copy)
    end
    def dup() : self
      return typeof(self).new(self)
    end
  end
  # Class holding a valid drawing context
  #
  #
  #
  # If you need to make OpenGL calls without having an
  # active window (like in a thread), you can use an
  # instance of this class to get a valid context.
  #
  # Having a valid context is necessary for *every* OpenGL call.
  #
  # Note that a context is only active in its current thread,
  # if you create a new thread it will have no valid context
  # by default.
  #
  # To use a `SF::Context` instance, just construct it and let it
  # live as long as you need a valid context. No explicit activation
  # is needed, all it has to do is to exist. Its destructor
  # will take care of deactivating and freeing all the attached
  # resources.
  #
  # Usage example:
  # ```c++
  # void threadFunction(void*)
  # {
  #    sf::Context context;
  #    // from now on, you have a valid context
  #
  #    // you can make OpenGL calls
  #    glClear(GL_DEPTH_BUFFER_BIT);
  # }
  # // the context is automatically deactivated and destroyed
  # // by the sf::Context destructor
  # ```
  class Context
    @_context : VoidCSFML::Context_Buffer = VoidCSFML::Context_Buffer.new(0u8)
    # Default constructor
    #
    # The constructor creates and activates the context
    def initialize()
      @_context = uninitialized VoidCSFML::Context_Buffer
      VoidCSFML.context_initialize(to_unsafe)
    end
    # Destructor
    #
    # The destructor deactivates and destroys the context
    def finalize()
      VoidCSFML.context_finalize(to_unsafe)
    end
    # Activate or deactivate explicitly the context
    #
    # * *active* - True to activate, false to deactivate
    #
    # *Returns:* True on success, false on failure
    def active=(active : Bool) : Bool
      VoidCSFML.context_setactive_GZq(to_unsafe, active, out result)
      return result
    end
    # Construct a in-memory context
    #
    # This constructor is for internal use, you don't need
    # to bother with it.
    #
    # * *settings* - Creation parameters
    # * *width* -    Back buffer width
    # * *height* -   Back buffer height
    def initialize(settings : ContextSettings, width : Int, height : Int)
      @_context = uninitialized VoidCSFML::Context_Buffer
      VoidCSFML.context_initialize_Fw4emSemS(to_unsafe, settings, LibC::UInt.new(width), LibC::UInt.new(height))
    end
    include GlResource
    include NonCopyable
    # :nodoc:
    def to_unsafe()
      pointerof(@_context).as(Void*)
    end
    # :nodoc:
    def inspect(io)
      to_s(io)
    end
  end
  # Give access to the real-time state of the joysticks
  #
  #
  #
  # `SF::Joystick` provides an interface to the state of the
  # joysticks. It only contains static functions, so it's not
  # meant to be instantiated. Instead, each joystick is identified
  # by an index that is passed to the functions of this class.
  #
  # This class allows users to query the state of joysticks at any
  # time and directly, without having to deal with a window and
  # its events. Compared to the JoystickMoved, JoystickButtonPressed
  # and JoystickButtonReleased events, `SF::Joystick` can retrieve the
  # state of axes and buttons of joysticks at any time
  # (you don't need to store and update a boolean on your side
  # in order to know if a button is pressed or released), and you
  # always get the real state of joysticks, even if they are
  # moved, pressed or released when your window is out of focus
  # and no event is triggered.
  #
  # SFML supports:
  # * 8 joysticks (`SF::Joystick::Count`)
  # * 32 buttons per joystick (`SF::Joystick::ButtonCount`)
  # * 8 axes per joystick (`SF::Joystick::AxisCount`)
  #
  # Unlike the keyboard or mouse, the state of joysticks is sometimes
  # not directly available (depending on the OS), therefore an update()
  # function must be called in order to update the current state of
  # joysticks. When you have a window with event handling, this is done
  # automatically, you don't need to call anything. But if you have no
  # window, or if you want to check joysticks state before creating one,
  # you must call `SF::Joystick::update` explicitly.
  #
  # Usage example:
  # ```c++
  # // Is joystick #0 connected?
  # bool connected = sf::Joystick::isConnected(0);
  #
  # // How many buttons does joystick #0 support?
  # unsigned int buttons = sf::Joystick::getButtonCount(0);
  #
  # // Does joystick #0 define a X axis?
  # bool hasX = sf::Joystick::hasAxis(0, sf::Joystick::X);
  #
  # // Is button #2 pressed on joystick #0?
  # bool pressed = sf::Joystick::isButtonPressed(0, 2);
  #
  # // What's the current position of the Y axis on joystick #0?
  # float position = sf::Joystick::getAxisPosition(0, sf::Joystick::Y);
  # ```
  #
  # *See also:* `SF::Keyboard`, `SF::Mouse`
  module Joystick
    # Constants related to joysticks capabilities
    # Maximum number of supported joysticks
    Count = 8
    # Maximum number of supported buttons
    ButtonCount = 32
    # Maximum number of supported axes
    AxisCount = 8
    # Axes supported by SFML joysticks
    enum Axis
      # The X axis
      X
      # The Y axis
      Y
      # The Z axis
      Z
      # The R axis
      R
      # The U axis
      U
      # The V axis
      V
      # The X axis of the point-of-view hat
      PovX
      # The Y axis of the point-of-view hat
      PovY
    end
    _sf_enum Joystick::Axis
    # Structure holding a joystick's identification
    class Identification
      @_joystick_identification : VoidCSFML::Joystick_Identification_Buffer = VoidCSFML::Joystick_Identification_Buffer.new(0u8)
      def initialize()
        @_joystick_identification = uninitialized VoidCSFML::Joystick_Identification_Buffer
        VoidCSFML.joystick_identification_initialize(to_unsafe)
      end
      # Name of the joystick
      def name() : String
        VoidCSFML.joystick_identification_getname(to_unsafe, out result)
        return String.build { |io| while (v = result.value) != '\0'; io << v; result += 1; end }
      end
      def name=(name : String)
        VoidCSFML.joystick_identification_setname_Lnu(to_unsafe, name.size, name.chars)
      end
      # Manufacturer identifier
      def vendor_id() : UInt32
        VoidCSFML.joystick_identification_getvendorid(to_unsafe, out result)
        return result
      end
      def vendor_id=(vendor_id : Int)
        VoidCSFML.joystick_identification_setvendorid_emS(to_unsafe, LibC::UInt.new(vendor_id))
      end
      # Product identifier
      def product_id() : UInt32
        VoidCSFML.joystick_identification_getproductid(to_unsafe, out result)
        return result
      end
      def product_id=(product_id : Int)
        VoidCSFML.joystick_identification_setproductid_emS(to_unsafe, LibC::UInt.new(product_id))
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@_joystick_identification).as(Void*)
      end
      # :nodoc:
      def inspect(io)
        to_s(io)
      end
      # :nodoc:
      def initialize(copy : Joystick::Identification)
        @_joystick_identification = uninitialized VoidCSFML::Joystick_Identification_Buffer
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.joystick_identification_initialize_ISj(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Check if a joystick is connected
    #
    # * *joystick* - Index of the joystick to check
    #
    # *Returns:* True if the joystick is connected, false otherwise
    def self.connected?(joystick : Int) : Bool
      VoidCSFML.joystick_isconnected_emS(LibC::UInt.new(joystick), out result)
      return result
    end
    # Return the number of buttons supported by a joystick
    #
    # If the joystick is not connected, this function returns 0.
    #
    # * *joystick* - Index of the joystick
    #
    # *Returns:* Number of buttons supported by the joystick
    def self.get_button_count(joystick : Int) : UInt32
      VoidCSFML.joystick_getbuttoncount_emS(LibC::UInt.new(joystick), out result)
      return result
    end
    # Check if a joystick supports a given axis
    #
    # If the joystick is not connected, this function returns false.
    #
    # * *joystick* - Index of the joystick
    # * *axis* -     Axis to check
    #
    # *Returns:* True if the joystick supports the axis, false otherwise
    def self.axis?(joystick : Int, axis : Joystick::Axis) : Bool
      VoidCSFML.joystick_hasaxis_emSHdj(LibC::UInt.new(joystick), axis, out result)
      return result
    end
    # Check if a joystick button is pressed
    #
    # If the joystick is not connected, this function returns false.
    #
    # * *joystick* - Index of the joystick
    # * *button* -   Button to check
    #
    # *Returns:* True if the button is pressed, false otherwise
    def self.button_pressed?(joystick : Int, button : Int) : Bool
      VoidCSFML.joystick_isbuttonpressed_emSemS(LibC::UInt.new(joystick), LibC::UInt.new(button), out result)
      return result
    end
    # Get the current position of a joystick axis
    #
    # If the joystick is not connected, this function returns 0.
    #
    # * *joystick* - Index of the joystick
    # * *axis* -     Axis to check
    #
    # *Returns:* Current position of the axis, in range [-100 .. 100]
    def self.get_axis_position(joystick : Int, axis : Joystick::Axis) : Float32
      VoidCSFML.joystick_getaxisposition_emSHdj(LibC::UInt.new(joystick), axis, out result)
      return result
    end
    # Get the joystick information
    #
    # * *joystick* - Index of the joystick
    #
    # *Returns:* Structure containing joystick information.
    def self.get_identification(joystick : Int) : Joystick::Identification
      result = Joystick::Identification.allocate
      VoidCSFML.joystick_getidentification_emS(LibC::UInt.new(joystick), result)
      return result
    end
    # Update the states of all joysticks
    #
    # This function is used internally by SFML, so you normally
    # don't have to call it explicitly. However, you may need to
    # call it if you have no window yet (or no window at all):
    # in this case the joystick states are not updated automatically.
    def self.update()
      VoidCSFML.joystick_update()
    end
  end
  # Give access to the real-time state of the keyboard
  #
  #
  #
  # `SF::Keyboard` provides an interface to the state of the
  # keyboard. It only contains static functions (a single
  # keyboard is assumed), so it's not meant to be instantiated.
  #
  # This class allows users to query the keyboard state at any
  # time and directly, without having to deal with a window and
  # its events. Compared to the KeyPressed and KeyReleased events,
  # `SF::Keyboard` can retrieve the state of a key at any time
  # (you don't need to store and update a boolean on your side
  # in order to know if a key is pressed or released), and you
  # always get the real state of the keyboard, even if keys are
  # pressed or released when your window is out of focus and no
  # event is triggered.
  #
  # Usage example:
  # ```c++
  # if (sf::Keyboard::isKeyPressed(sf::Keyboard::Left))
  # {
  #     // move left...
  # }
  # else if (sf::Keyboard::isKeyPressed(sf::Keyboard::Right))
  # {
  #     // move right...
  # }
  # else if (sf::Keyboard::isKeyPressed(sf::Keyboard::Escape))
  # {
  #     // quit...
  # }
  # ```
  #
  # *See also:* `SF::Joystick`, `SF::Mouse`, `SF::Touch`
  module Keyboard
    # Key codes
    enum Key
      # Unhandled key
      Unknown = -1
      # The A key
      A = 0
      # The B key
      B
      # The C key
      C
      # The D key
      D
      # The E key
      E
      # The F key
      F
      # The G key
      G
      # The H key
      H
      # The I key
      I
      # The J key
      J
      # The K key
      K
      # The L key
      L
      # The M key
      M
      # The N key
      N
      # The O key
      O
      # The P key
      P
      # The Q key
      Q
      # The R key
      R
      # The S key
      S
      # The T key
      T
      # The U key
      U
      # The V key
      V
      # The W key
      W
      # The X key
      X
      # The Y key
      Y
      # The Z key
      Z
      # The 0 key
      Num0
      # The 1 key
      Num1
      # The 2 key
      Num2
      # The 3 key
      Num3
      # The 4 key
      Num4
      # The 5 key
      Num5
      # The 6 key
      Num6
      # The 7 key
      Num7
      # The 8 key
      Num8
      # The 9 key
      Num9
      # The Escape key
      Escape
      # The left Control key
      LControl
      # The left Shift key
      LShift
      # The left Alt key
      LAlt
      # The left OS specific key: window (Windows and Linux), apple (MacOS X), ...
      LSystem
      # The right Control key
      RControl
      # The right Shift key
      RShift
      # The right Alt key
      RAlt
      # The right OS specific key: window (Windows and Linux), apple (MacOS X), ...
      RSystem
      # The Menu key
      Menu
      # The [ key
      LBracket
      # The ] key
      RBracket
      # The ; key
      SemiColon
      # The , key
      Comma
      # The . key
      Period
      # The ' key
      Quote
      # The / key
      Slash
      # The \ key
      BackSlash
      # The ~ key
      Tilde
      # The = key
      Equal
      # The - key
      Dash
      # The Space key
      Space
      # The Return key
      Return
      # The Backspace key
      BackSpace
      # The Tabulation key
      Tab
      # The Page up key
      PageUp
      # The Page down key
      PageDown
      # The End key
      End
      # The Home key
      Home
      # The Insert key
      Insert
      # The Delete key
      Delete
      # The + key
      Add
      # The - key
      Subtract
      # The * key
      Multiply
      # The / key
      Divide
      # Left arrow
      Left
      # Right arrow
      Right
      # Up arrow
      Up
      # Down arrow
      Down
      # The numpad 0 key
      Numpad0
      # The numpad 1 key
      Numpad1
      # The numpad 2 key
      Numpad2
      # The numpad 3 key
      Numpad3
      # The numpad 4 key
      Numpad4
      # The numpad 5 key
      Numpad5
      # The numpad 6 key
      Numpad6
      # The numpad 7 key
      Numpad7
      # The numpad 8 key
      Numpad8
      # The numpad 9 key
      Numpad9
      # The F1 key
      F1
      # The F2 key
      F2
      # The F3 key
      F3
      # The F4 key
      F4
      # The F5 key
      F5
      # The F6 key
      F6
      # The F7 key
      F7
      # The F8 key
      F8
      # The F9 key
      F9
      # The F10 key
      F10
      # The F11 key
      F11
      # The F12 key
      F12
      # The F13 key
      F13
      # The F14 key
      F14
      # The F15 key
      F15
      # The Pause key
      Pause
      # Keep last -- the total number of keyboard keys
      KeyCount
    end
    _sf_enum Keyboard::Key
    # Check if a key is pressed
    #
    # * *key* - Key to check
    #
    # *Returns:* True if the key is pressed, false otherwise
    def self.key_pressed?(key : Keyboard::Key) : Bool
      VoidCSFML.keyboard_iskeypressed_cKW(key, out result)
      return result
    end
    # Show or hide the virtual keyboard
    #
    # Warning: the virtual keyboard is not supported on all
    # systems. It will typically be implemented on mobile OSes
    # (Android, iOS) but not on desktop OSes (Windows, Linux, ...).
    #
    # If the virtual keyboard is not available, this function does
    # nothing.
    #
    # * *visible* - True to show, false to hide
    def self.virtual_keyboard_visible=(visible : Bool)
      VoidCSFML.keyboard_setvirtualkeyboardvisible_GZq(visible)
    end
  end
  # Give access to the real-time state of the mouse
  #
  #
  #
  # `SF::Mouse` provides an interface to the state of the
  # mouse. It only contains static functions (a single
  # mouse is assumed), so it's not meant to be instantiated.
  #
  # This class allows users to query the mouse state at any
  # time and directly, without having to deal with a window and
  # its events. Compared to the MouseMoved, MouseButtonPressed
  # and MouseButtonReleased events, `SF::Mouse` can retrieve the
  # state of the cursor and the buttons at any time
  # (you don't need to store and update a boolean on your side
  # in order to know if a button is pressed or released), and you
  # always get the real state of the mouse, even if it is
  # moved, pressed or released when your window is out of focus
  # and no event is triggered.
  #
  # The setPosition and getPosition functions can be used to change
  # or retrieve the current position of the mouse pointer. There are
  # two versions: one that operates in global coordinates (relative
  # to the desktop) and one that operates in window coordinates
  # (relative to a specific window).
  #
  # Usage example:
  # ```c++
  # if (sf::Mouse::isButtonPressed(sf::Mouse::Left))
  # {
  #     // left click...
  # }
  #
  # // get global mouse position
  # sf::Vector2i position = sf::Mouse::getPosition();
  #
  # // set mouse position relative to a window
  # sf::Mouse::setPosition(sf::Vector2i(100, 200), window);
  # ```
  #
  # *See also:* `SF::Joystick`, `SF::Keyboard`, `SF::Touch`
  module Mouse
    # Mouse buttons
    enum Button
      # The left mouse button
      Left
      # The right mouse button
      Right
      # The middle (wheel) mouse button
      Middle
      # The first extra mouse button
      XButton1
      # The second extra mouse button
      XButton2
      # Keep last -- the total number of mouse buttons
      ButtonCount
    end
    _sf_enum Mouse::Button
    # Mouse wheels
    enum Wheel
      # The vertical mouse wheel
      VerticalWheel
      # The horizontal mouse wheel
      HorizontalWheel
    end
    _sf_enum Mouse::Wheel
    # Check if a mouse button is pressed
    #
    # * *button* - Button to check
    #
    # *Returns:* True if the button is pressed, false otherwise
    def self.button_pressed?(button : Mouse::Button) : Bool
      VoidCSFML.mouse_isbuttonpressed_Zxg(button, out result)
      return result
    end
    # Get the current position of the mouse in desktop coordinates
    #
    # This function returns the global position of the mouse
    # cursor on the desktop.
    #
    # *Returns:* Current position of the mouse
    def self.position() : Vector2i
      result = Vector2i.allocate
      VoidCSFML.mouse_getposition(result)
      return result
    end
    # Get the current position of the mouse in window coordinates
    #
    # This function returns the current position of the mouse
    # cursor, relative to the given window.
    #
    # * *relative_to* - Reference window
    #
    # *Returns:* Current position of the mouse
    def self.get_position(relative_to : Window) : Vector2i
      result = Vector2i.allocate
      VoidCSFML.mouse_getposition_JRh(relative_to, result)
      return result
    end
    # Set the current position of the mouse in desktop coordinates
    #
    # This function sets the global position of the mouse
    # cursor on the desktop.
    #
    # * *position* - New position of the mouse
    def self.position=(position : Vector2|Tuple)
      position = Vector2i.new(position[0].to_i32, position[1].to_i32)
      VoidCSFML.mouse_setposition_ufV(position)
    end
    # Set the current position of the mouse in window coordinates
    #
    # This function sets the current position of the mouse
    # cursor, relative to the given window.
    #
    # * *position* - New position of the mouse
    # * *relative_to* - Reference window
    def self.set_position(position : Vector2|Tuple, relative_to : Window)
      position = Vector2i.new(position[0].to_i32, position[1].to_i32)
      VoidCSFML.mouse_setposition_ufVJRh(position, relative_to)
    end
  end
  # Give access to the real-time state of the sensors
  #
  #
  #
  # `SF::Sensor` provides an interface to the state of the
  # various sensors that a device provides. It only contains static
  # functions, so it's not meant to be instantiated.
  #
  # This class allows users to query the sensors values at any
  # time and directly, without having to deal with a window and
  # its events. Compared to the SensorChanged event, `SF::Sensor`
  # can retrieve the state of a sensor at any time (you don't need to
  # store and update its current value on your side).
  #
  # Depending on the OS and hardware of the device (phone, tablet, ...),
  # some sensor types may not be available. You should always check
  # the availability of a sensor before trying to read it, with the
  # `SF::Sensor::isAvailable` function.
  #
  # You may wonder why some sensor types look so similar, for example
  # Accelerometer and Gravity / UserAcceleration. The first one
  # is the raw measurement of the acceleration, and takes into account
  # both the earth gravity and the user movement. The others are
  # more precise: they provide these components separately, which is
  # usually more useful. In fact they are not direct sensors, they
  # are computed internally based on the raw acceleration and other sensors.
  # This is exactly the same for Gyroscope vs Orientation.
  #
  # Because sensors consume a non-negligible amount of current, they are
  # all disabled by default. You must call `SF::Sensor::setEnabled` for each
  # sensor in which you are interested.
  #
  # Usage example:
  # ```c++
  # if (sf::Sensor::isAvailable(sf::Sensor::Gravity))
  # {
  #     // gravity sensor is available
  # }
  #
  # // enable the gravity sensor
  # sf::Sensor::setEnabled(sf::Sensor::Gravity, true);
  #
  # // get the current value of gravity
  # sf::Vector3f gravity = sf::Sensor::getValue(sf::Sensor::Gravity);
  # ```
  module Sensor
    # Sensor type
    enum Type
      # Measures the raw acceleration (m/s^2)
      Accelerometer
      # Measures the raw rotation rates (degrees/s)
      Gyroscope
      # Measures the ambient magnetic field (micro-teslas)
      Magnetometer
      # Measures the direction and intensity of gravity, independent of device acceleration (m/s^2)
      Gravity
      # Measures the direction and intensity of device acceleration, independent of the gravity (m/s^2)
      UserAcceleration
      # Measures the absolute 3D orientation (degrees)
      Orientation
      # Keep last -- the total number of sensor types
      Count
    end
    _sf_enum Sensor::Type
    # Check if a sensor is available on the underlying platform
    #
    # * *sensor* - Sensor to check
    #
    # *Returns:* True if the sensor is available, false otherwise
    def self.available?(sensor : Sensor::Type) : Bool
      VoidCSFML.sensor_isavailable_jRE(sensor, out result)
      return result
    end
    # Enable or disable a sensor
    #
    # All sensors are disabled by default, to avoid consuming too
    # much battery power. Once a sensor is enabled, it starts
    # sending events of the corresponding type.
    #
    # This function does nothing if the sensor is unavailable.
    #
    # * *sensor* -  Sensor to enable
    # * *enabled* - True to enable, false to disable
    def self.set_enabled(sensor : Sensor::Type, enabled : Bool)
      VoidCSFML.sensor_setenabled_jREGZq(sensor, enabled)
    end
    # Get the current sensor value
    #
    # * *sensor* - Sensor to read
    #
    # *Returns:* The current sensor value
    def self.get_value(sensor : Sensor::Type) : Vector3f
      result = Vector3f.allocate
      VoidCSFML.sensor_getvalue_jRE(sensor, result)
      return result
    end
  end
  # Defines a system event and its parameters
  #
  #
  #
  # `SF::Event` holds all the informations about a system event
  # that just happened. Events are retrieved using the
  # `SF::Window::pollEvent` and `SF::Window::waitEvent` functions.
  #
  # A `SF::Event` instance contains the type of the event
  # (mouse moved, key pressed, window closed, ...) as well
  # as the details about this particular event. Please note that
  # the event parameters are defined in a union, which means that
  # only the member matching the type of the event will be properly
  # filled; all other members will have undefined values and must not
  # be read if the type of the event doesn't match. For example,
  # if you received a KeyPressed event, then you must read the
  # event.key member, all other members such as event.MouseMove
  # or event.text will have undefined values.
  #
  # Usage example:
  # ```c++
  # sf::Event event;
  # while (window.pollEvent(event))
  # {
  #     // Request for closing the window
  #     if (event.type == sf::Event::Closed)
  #         window.close();
  #
  #     // The escape key was pressed
  #     if ((event.type == sf::Event::KeyPressed) && (event.key.code == sf::Keyboard::Escape))
  #         window.close();
  #
  #     // The window was resized
  #     if (event.type == sf::Event::Resized)
  #         doSomethingWithTheNewSize(event.size.width, event.size.height);
  #
  #     // etc ...
  # }
  # ```
  abstract struct Event
    # Size events parameters (Resized)
    abstract struct SizeEvent < Event
      def initialize()
        @width = uninitialized UInt32
        @height = uninitialized UInt32
        VoidCSFML.event_sizeevent_initialize(to_unsafe)
      end
      @width : LibC::UInt
      @height : LibC::UInt
      @width : LibC::UInt
      # New width, in pixels
      def width : UInt32
        @width
      end
      def width=(width : Int)
        @width = LibC::UInt.new(width)
      end
      @height : LibC::UInt
      # New height, in pixels
      def height : UInt32
        @height
      end
      def height=(height : Int)
        @height = LibC::UInt.new(height)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@width).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::SizeEvent)
        @width = uninitialized UInt32
        @height = uninitialized UInt32
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_sizeevent_initialize_isq(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Keyboard event parameters (KeyPressed, KeyReleased)
    abstract struct KeyEvent < Event
      def initialize()
        @code = uninitialized Keyboard::Key
        @alt = uninitialized Bool
        @control = uninitialized Bool
        @shift = uninitialized Bool
        @system = uninitialized Bool
        VoidCSFML.event_keyevent_initialize(to_unsafe)
      end
      @code : Keyboard::Key
      @alt : Bool
      @control : Bool
      @shift : Bool
      @system : Bool
      @code : Keyboard::Key
      # Code of the key that has been pressed
      def code : Keyboard::Key
        @code
      end
      def code=(code : Keyboard::Key)
        @code = code
      end
      @alt : Bool
      # Is the Alt key pressed?
      def alt : Bool
        @alt
      end
      def alt=(alt : Bool)
        @alt = alt
      end
      @control : Bool
      # Is the Control key pressed?
      def control : Bool
        @control
      end
      def control=(control : Bool)
        @control = control
      end
      @shift : Bool
      # Is the Shift key pressed?
      def shift : Bool
        @shift
      end
      def shift=(shift : Bool)
        @shift = shift
      end
      @system : Bool
      # Is the System key pressed?
      def system : Bool
        @system
      end
      def system=(system : Bool)
        @system = system
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@code).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::KeyEvent)
        @code = uninitialized Keyboard::Key
        @alt = uninitialized Bool
        @control = uninitialized Bool
        @shift = uninitialized Bool
        @system = uninitialized Bool
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_keyevent_initialize_wJ8(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Text event parameters (TextEntered)
    abstract struct TextEvent < Event
      def initialize()
        @unicode = uninitialized UInt32
        VoidCSFML.event_textevent_initialize(to_unsafe)
      end
      @unicode : UInt32
      @unicode : UInt32
      # UTF-32 Unicode value of the character
      def unicode : UInt32
        @unicode
      end
      def unicode=(unicode : Int)
        @unicode = UInt32.new(unicode)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@unicode).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::TextEvent)
        @unicode = uninitialized UInt32
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_textevent_initialize_uku(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Mouse move event parameters (MouseMoved)
    abstract struct MouseMoveEvent < Event
      def initialize()
        @x = uninitialized Int32
        @y = uninitialized Int32
        VoidCSFML.event_mousemoveevent_initialize(to_unsafe)
      end
      @x : LibC::Int
      @y : LibC::Int
      @x : LibC::Int
      # X position of the mouse pointer, relative to the left of the owner window
      def x : Int32
        @x
      end
      def x=(x : Int)
        @x = LibC::Int.new(x)
      end
      @y : LibC::Int
      # Y position of the mouse pointer, relative to the top of the owner window
      def y : Int32
        @y
      end
      def y=(y : Int)
        @y = LibC::Int.new(y)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@x).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::MouseMoveEvent)
        @x = uninitialized Int32
        @y = uninitialized Int32
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_mousemoveevent_initialize_1i3(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Mouse buttons events parameters
    #        (MouseButtonPressed, MouseButtonReleased)
    abstract struct MouseButtonEvent < Event
      def initialize()
        @button = uninitialized Mouse::Button
        @x = uninitialized Int32
        @y = uninitialized Int32
        VoidCSFML.event_mousebuttonevent_initialize(to_unsafe)
      end
      @button : Mouse::Button
      @x : LibC::Int
      @y : LibC::Int
      @button : Mouse::Button
      # Code of the button that has been pressed
      def button : Mouse::Button
        @button
      end
      def button=(button : Mouse::Button)
        @button = button
      end
      @x : LibC::Int
      # X position of the mouse pointer, relative to the left of the owner window
      def x : Int32
        @x
      end
      def x=(x : Int)
        @x = LibC::Int.new(x)
      end
      @y : LibC::Int
      # Y position of the mouse pointer, relative to the top of the owner window
      def y : Int32
        @y
      end
      def y=(y : Int)
        @y = LibC::Int.new(y)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@button).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::MouseButtonEvent)
        @button = uninitialized Mouse::Button
        @x = uninitialized Int32
        @y = uninitialized Int32
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_mousebuttonevent_initialize_Tjo(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Mouse wheel events parameters (MouseWheelMoved)
    #
    # *Deprecated:* This event is deprecated and potentially inaccurate.
    #             Use MouseWheelScrollEvent instead.
    abstract struct MouseWheelEvent < Event
      def initialize()
        @delta = uninitialized Int32
        @x = uninitialized Int32
        @y = uninitialized Int32
        VoidCSFML.event_mousewheelevent_initialize(to_unsafe)
      end
      @delta : LibC::Int
      @x : LibC::Int
      @y : LibC::Int
      @delta : LibC::Int
      # Number of ticks the wheel has moved (positive is up, negative is down)
      def delta : Int32
        @delta
      end
      def delta=(delta : Int)
        @delta = LibC::Int.new(delta)
      end
      @x : LibC::Int
      # X position of the mouse pointer, relative to the left of the owner window
      def x : Int32
        @x
      end
      def x=(x : Int)
        @x = LibC::Int.new(x)
      end
      @y : LibC::Int
      # Y position of the mouse pointer, relative to the top of the owner window
      def y : Int32
        @y
      end
      def y=(y : Int)
        @y = LibC::Int.new(y)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@delta).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::MouseWheelEvent)
        @delta = uninitialized Int32
        @x = uninitialized Int32
        @y = uninitialized Int32
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_mousewheelevent_initialize_Wk7(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Mouse wheel events parameters (MouseWheelScrolled)
    abstract struct MouseWheelScrollEvent < Event
      def initialize()
        @wheel = uninitialized Mouse::Wheel
        @delta = uninitialized Float32
        @x = uninitialized Int32
        @y = uninitialized Int32
        VoidCSFML.event_mousewheelscrollevent_initialize(to_unsafe)
      end
      @wheel : Mouse::Wheel
      @delta : LibC::Float
      @x : LibC::Int
      @y : LibC::Int
      @wheel : Mouse::Wheel
      # Which wheel (for mice with multiple ones)
      def wheel : Mouse::Wheel
        @wheel
      end
      def wheel=(wheel : Mouse::Wheel)
        @wheel = wheel
      end
      @delta : LibC::Float
      # Wheel offset (positive is up/left, negative is down/right). High-precision mice may use non-integral offsets.
      def delta : Float32
        @delta
      end
      def delta=(delta : Number)
        @delta = LibC::Float.new(delta)
      end
      @x : LibC::Int
      # X position of the mouse pointer, relative to the left of the owner window
      def x : Int32
        @x
      end
      def x=(x : Int)
        @x = LibC::Int.new(x)
      end
      @y : LibC::Int
      # Y position of the mouse pointer, relative to the top of the owner window
      def y : Int32
        @y
      end
      def y=(y : Int)
        @y = LibC::Int.new(y)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@wheel).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::MouseWheelScrollEvent)
        @wheel = uninitialized Mouse::Wheel
        @delta = uninitialized Float32
        @x = uninitialized Int32
        @y = uninitialized Int32
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_mousewheelscrollevent_initialize_Am0(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Joystick connection events parameters
    #        (JoystickConnected, JoystickDisconnected)
    abstract struct JoystickConnectEvent < Event
      def initialize()
        @joystick_id = uninitialized UInt32
        VoidCSFML.event_joystickconnectevent_initialize(to_unsafe)
      end
      @joystick_id : LibC::UInt
      @joystick_id : LibC::UInt
      # Index of the joystick (in range [0 .. Joystick::Count - 1])
      def joystick_id : UInt32
        @joystick_id
      end
      def joystick_id=(joystick_id : Int)
        @joystick_id = LibC::UInt.new(joystick_id)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@joystick_id).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::JoystickConnectEvent)
        @joystick_id = uninitialized UInt32
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_joystickconnectevent_initialize_rYL(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Joystick axis move event parameters (JoystickMoved)
    abstract struct JoystickMoveEvent < Event
      def initialize()
        @joystick_id = uninitialized UInt32
        @axis = uninitialized Joystick::Axis
        @position = uninitialized Float32
        VoidCSFML.event_joystickmoveevent_initialize(to_unsafe)
      end
      @joystick_id : LibC::UInt
      @axis : Joystick::Axis
      @position : LibC::Float
      @joystick_id : LibC::UInt
      # Index of the joystick (in range [0 .. Joystick::Count - 1])
      def joystick_id : UInt32
        @joystick_id
      end
      def joystick_id=(joystick_id : Int)
        @joystick_id = LibC::UInt.new(joystick_id)
      end
      @axis : Joystick::Axis
      # Axis on which the joystick moved
      def axis : Joystick::Axis
        @axis
      end
      def axis=(axis : Joystick::Axis)
        @axis = axis
      end
      @position : LibC::Float
      # New position on the axis (in range [-100 .. 100])
      def position : Float32
        @position
      end
      def position=(position : Number)
        @position = LibC::Float.new(position)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@joystick_id).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::JoystickMoveEvent)
        @joystick_id = uninitialized UInt32
        @axis = uninitialized Joystick::Axis
        @position = uninitialized Float32
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_joystickmoveevent_initialize_S8f(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Joystick buttons events parameters
    #        (JoystickButtonPressed, JoystickButtonReleased)
    abstract struct JoystickButtonEvent < Event
      def initialize()
        @joystick_id = uninitialized UInt32
        @button = uninitialized UInt32
        VoidCSFML.event_joystickbuttonevent_initialize(to_unsafe)
      end
      @joystick_id : LibC::UInt
      @button : LibC::UInt
      @joystick_id : LibC::UInt
      # Index of the joystick (in range [0 .. Joystick::Count - 1])
      def joystick_id : UInt32
        @joystick_id
      end
      def joystick_id=(joystick_id : Int)
        @joystick_id = LibC::UInt.new(joystick_id)
      end
      @button : LibC::UInt
      # Index of the button that has been pressed (in range [0 .. Joystick::ButtonCount - 1])
      def button : UInt32
        @button
      end
      def button=(button : Int)
        @button = LibC::UInt.new(button)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@joystick_id).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::JoystickButtonEvent)
        @joystick_id = uninitialized UInt32
        @button = uninitialized UInt32
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_joystickbuttonevent_initialize_V0a(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Touch events parameters (TouchBegan, TouchMoved, TouchEnded)
    abstract struct TouchEvent < Event
      def initialize()
        @finger = uninitialized UInt32
        @x = uninitialized Int32
        @y = uninitialized Int32
        VoidCSFML.event_touchevent_initialize(to_unsafe)
      end
      @finger : LibC::UInt
      @x : LibC::Int
      @y : LibC::Int
      @finger : LibC::UInt
      # Index of the finger in case of multi-touch events
      def finger : UInt32
        @finger
      end
      def finger=(finger : Int)
        @finger = LibC::UInt.new(finger)
      end
      @x : LibC::Int
      # X position of the touch, relative to the left of the owner window
      def x : Int32
        @x
      end
      def x=(x : Int)
        @x = LibC::Int.new(x)
      end
      @y : LibC::Int
      # Y position of the touch, relative to the top of the owner window
      def y : Int32
        @y
      end
      def y=(y : Int)
        @y = LibC::Int.new(y)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@finger).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::TouchEvent)
        @finger = uninitialized UInt32
        @x = uninitialized Int32
        @y = uninitialized Int32
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_touchevent_initialize_1F1(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # Sensor event parameters (SensorChanged)
    abstract struct SensorEvent < Event
      def initialize()
        @type = uninitialized Sensor::Type
        @x = uninitialized Float32
        @y = uninitialized Float32
        @z = uninitialized Float32
        VoidCSFML.event_sensorevent_initialize(to_unsafe)
      end
      @type : Sensor::Type
      @x : LibC::Float
      @y : LibC::Float
      @z : LibC::Float
      @type : Sensor::Type
      # Type of the sensor
      def type : Sensor::Type
        @type
      end
      def type=(type : Sensor::Type)
        @type = type
      end
      @x : LibC::Float
      # Current value of the sensor on X axis
      def x : Float32
        @x
      end
      def x=(x : Number)
        @x = LibC::Float.new(x)
      end
      @y : LibC::Float
      # Current value of the sensor on Y axis
      def y : Float32
        @y
      end
      def y=(y : Number)
        @y = LibC::Float.new(y)
      end
      @z : LibC::Float
      # Current value of the sensor on Z axis
      def z : Float32
        @z
      end
      def z=(z : Number)
        @z = LibC::Float.new(z)
      end
      # :nodoc:
      def to_unsafe()
        pointerof(@type).as(Void*)
      end
      # :nodoc:
      def initialize(copy : Event::SensorEvent)
        @type = uninitialized Sensor::Type
        @x = uninitialized Float32
        @y = uninitialized Float32
        @z = uninitialized Float32
        as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
        VoidCSFML.event_sensorevent_initialize_L9(to_unsafe, copy)
      end
      def dup() : self
        return typeof(self).new(self)
      end
    end
    # The window requested to be closed (no data)
    struct Closed < Event
    end
    # The window was resized (data in event.size)
    struct Resized < SizeEvent
    end
    # The window lost the focus (no data)
    struct LostFocus < Event
    end
    # The window gained the focus (no data)
    struct GainedFocus < Event
    end
    # A character was entered (data in event.text)
    struct TextEntered < TextEvent
    end
    # A key was pressed (data in event.key)
    struct KeyPressed < KeyEvent
    end
    # A key was released (data in event.key)
    struct KeyReleased < KeyEvent
    end
    # The mouse wheel was scrolled (data in event.mouseWheel) (deprecated)
    struct MouseWheelMoved < MouseWheelEvent
    end
    # The mouse wheel was scrolled (data in event.mouseWheelScroll)
    struct MouseWheelScrolled < MouseWheelScrollEvent
    end
    # A mouse button was pressed (data in event.mouseButton)
    struct MouseButtonPressed < MouseButtonEvent
    end
    # A mouse button was released (data in event.mouseButton)
    struct MouseButtonReleased < MouseButtonEvent
    end
    # The mouse cursor moved (data in event.mouseMove)
    struct MouseMoved < MouseMoveEvent
    end
    # The mouse cursor entered the area of the window (no data)
    struct MouseEntered < Event
    end
    # The mouse cursor left the area of the window (no data)
    struct MouseLeft < Event
    end
    # A joystick button was pressed (data in event.joystickButton)
    struct JoystickButtonPressed < JoystickButtonEvent
    end
    # A joystick button was released (data in event.joystickButton)
    struct JoystickButtonReleased < JoystickButtonEvent
    end
    # The joystick moved along an axis (data in event.joystickMove)
    struct JoystickMoved < JoystickMoveEvent
    end
    # A joystick was connected (data in event.joystickConnect)
    struct JoystickConnected < JoystickConnectEvent
    end
    # A joystick was disconnected (data in event.joystickConnect)
    struct JoystickDisconnected < JoystickConnectEvent
    end
    # A touch event began (data in event.touch)
    struct TouchBegan < TouchEvent
    end
    # A touch moved (data in event.touch)
    struct TouchMoved < TouchEvent
    end
    # A touch event ended (data in event.touch)
    struct TouchEnded < TouchEvent
    end
    # A sensor value changed (data in event.sensor)
    struct SensorChanged < SensorEvent
    end
    # :nodoc:
    def to_unsafe()
      pointerof(@type).as(Void*)
    end
    def dup() : self
      return typeof(self).new(self)
    end
  end
  # Give access to the real-time state of the touches
  #
  #
  #
  # `SF::Touch` provides an interface to the state of the
  # touches. It only contains static functions, so it's not
  # meant to be instantiated.
  #
  # This class allows users to query the touches state at any
  # time and directly, without having to deal with a window and
  # its events. Compared to the TouchBegan, TouchMoved
  # and TouchEnded events, `SF::Touch` can retrieve the
  # state of the touches at any time (you don't need to store and
  # update a boolean on your side in order to know if a touch is down),
  # and you always get the real state of the touches, even if they
  # happen when your window is out of focus and no event is triggered.
  #
  # The getPosition function can be used to retrieve the current
  # position of a touch. There are two versions: one that operates
  # in global coordinates (relative to the desktop) and one that
  # operates in window coordinates (relative to a specific window).
  #
  # Touches are identified by an index (the "finger"), so that in
  # multi-touch events, individual touches can be tracked correctly.
  # As long as a finger touches the screen, it will keep the same index
  # even if other fingers start or stop touching the screen in the
  # meantime. As a consequence, active touch indices may not always be
  # sequential (i.e. touch number 0 may be released while touch number 1
  # is still down).
  #
  # Usage example:
  # ```c++
  # if (sf::Touch::isDown(0))
  # {
  #     // touch 0 is down
  # }
  #
  # // get global position of touch 1
  # sf::Vector2i globalPos = sf::Touch::getPosition(1);
  #
  # // get position of touch 1 relative to a window
  # sf::Vector2i relativePos = sf::Touch::getPosition(1, window);
  # ```
  #
  # *See also:* `SF::Joystick`, `SF::Keyboard`, `SF::Mouse`
  module Touch
    # Check if a touch event is currently down
    #
    # * *finger* - Finger index
    #
    # *Returns:* True if *finger* is currently touching the screen, false otherwise
    def self.down?(finger : Int) : Bool
      VoidCSFML.touch_isdown_emS(LibC::UInt.new(finger), out result)
      return result
    end
    # Get the current position of a touch in desktop coordinates
    #
    # This function returns the current touch position
    # in global (desktop) coordinates.
    #
    # * *finger* - Finger index
    #
    # *Returns:* Current position of *finger,* or undefined if it's not down
    def self.get_position(finger : Int) : Vector2i
      result = Vector2i.allocate
      VoidCSFML.touch_getposition_emS(LibC::UInt.new(finger), result)
      return result
    end
    # Get the current position of a touch in window coordinates
    #
    # This function returns the current touch position
    # in global (desktop) coordinates.
    #
    # * *finger* - Finger index
    # * *relative_to* - Reference window
    #
    # *Returns:* Current position of *finger,* or undefined if it's not down
    def self.get_position(finger : Int, relative_to : Window) : Vector2i
      result = Vector2i.allocate
      VoidCSFML.touch_getposition_emSJRh(LibC::UInt.new(finger), relative_to, result)
      return result
    end
  end
  # VideoMode defines a video mode (width, height, bpp)
  #
  #
  #
  # A video mode is defined by a width and a height (in pixels)
  # and a depth (in bits per pixel). Video modes are used to
  # setup windows (`SF::Window`) at creation time.
  #
  # The main usage of video modes is for fullscreen mode:
  # indeed you must use one of the valid video modes
  # allowed by the OS (which are defined by what the monitor
  # and the graphics card support), otherwise your window
  # creation will just fail.
  #
  # `SF::VideoMode` provides a static function for retrieving
  # the list of all the video modes supported by the system:
  # getFullscreenModes().
  #
  # A custom video mode can also be checked directly for
  # fullscreen compatibility with its isValid() function.
  #
  # Additionally, `SF::VideoMode` provides a static function
  # to get the mode currently used by the desktop: getDesktopMode().
  # This allows to build windows with the same size or pixel
  # depth as the current resolution.
  #
  # Usage example:
  # ```c++
  # // Display the list of all the video modes available for fullscreen
  # std::vector<sf::VideoMode> modes = sf::VideoMode::getFullscreenModes();
  # for (std::size_t i = 0; i < modes.size(); ++i)
  # {
  #     sf::VideoMode mode = modes[i];
  #     std::cout << "Mode #" << i << ": "
  #               << mode.width << "x" << mode.height << " - "
  #               << mode.bitsPerPixel << " bpp" << std::endl;
  # }
  #
  # // Create a window with the same pixel depth as the desktop
  # sf::VideoMode desktop = sf::VideoMode::getDesktopMode();
  # window.create(sf::VideoMode(1024, 768, desktop.bitsPerPixel), "SFML window");
  # ```
  struct VideoMode
    @width : LibC::UInt
    @height : LibC::UInt
    @bits_per_pixel : LibC::UInt
    # Default constructor
    #
    # This constructors initializes all members to 0.
    def initialize()
      @width = uninitialized UInt32
      @height = uninitialized UInt32
      @bits_per_pixel = uninitialized UInt32
      VoidCSFML.videomode_initialize(to_unsafe)
    end
    # Construct the video mode with its attributes
    #
    # * *mode_width* -        Width in pixels
    # * *mode_height* -       Height in pixels
    # * *mode_bits_per_pixel* - Pixel depths in bits per pixel
    def initialize(width : Int, height : Int, bits_per_pixel : Int = 32)
      @width = uninitialized UInt32
      @height = uninitialized UInt32
      @bits_per_pixel = uninitialized UInt32
      VoidCSFML.videomode_initialize_emSemSemS(to_unsafe, LibC::UInt.new(width), LibC::UInt.new(height), LibC::UInt.new(bits_per_pixel))
    end
    # Get the current desktop video mode
    #
    # *Returns:* Current desktop video mode
    def self.desktop_mode() : VideoMode
      result = VideoMode.allocate
      VoidCSFML.videomode_getdesktopmode(result)
      return result
    end
    # Retrieve all the video modes supported in fullscreen mode
    #
    # When creating a fullscreen window, the video mode is restricted
    # to be compatible with what the graphics driver and monitor
    # support. This function returns the complete list of all video
    # modes that can be used in fullscreen mode.
    # The returned array is sorted from best to worst, so that
    # the first element will always give the best mode (higher
    # width, height and bits-per-pixel).
    #
    # *Returns:* Array containing all the supported fullscreen modes
    def self.fullscreen_modes() : Array(VideoMode)
      VoidCSFML.videomode_getfullscreenmodes(out result, out result_size)
      return Array.new(result_size.to_i) { |i| result.as(VideoMode*)[i] }
    end
    # Tell whether or not the video mode is valid
    #
    # The validity of video modes is only relevant when using
    # fullscreen windows; otherwise any video mode can be used
    # with no restriction.
    #
    # *Returns:* True if the video mode is valid for fullscreen mode
    def valid?() : Bool
      VoidCSFML.videomode_isvalid(to_unsafe, out result)
      return result
    end
    @width : LibC::UInt
    # Video mode width, in pixels
    def width : UInt32
      @width
    end
    def width=(width : Int)
      @width = LibC::UInt.new(width)
    end
    @height : LibC::UInt
    # Video mode height, in pixels
    def height : UInt32
      @height
    end
    def height=(height : Int)
      @height = LibC::UInt.new(height)
    end
    @bits_per_pixel : LibC::UInt
    # Video mode pixel depth, in bits per pixels
    def bits_per_pixel : UInt32
      @bits_per_pixel
    end
    def bits_per_pixel=(bits_per_pixel : Int)
      @bits_per_pixel = LibC::UInt.new(bits_per_pixel)
    end
    #
    # Overload of == operator to compare two video modes
    #
    # * *left* -  Left operand (a video mode)
    # * *right* - Right operand (a video mode)
    #
    # *Returns:* True if modes are equal
    def ==(right : VideoMode) : Bool
      VoidCSFML.operator_eq_asWasW(to_unsafe, right, out result)
      return result
    end
    #
    # Overload of != operator to compare two video modes
    #
    # * *left* -  Left operand (a video mode)
    # * *right* - Right operand (a video mode)
    #
    # *Returns:* True if modes are different
    def !=(right : VideoMode) : Bool
      VoidCSFML.operator_ne_asWasW(to_unsafe, right, out result)
      return result
    end
    #
    # Overload of &lt; operator to compare video modes
    #
    # * *left* -  Left operand (a video mode)
    # * *right* - Right operand (a video mode)
    #
    # *Returns:* True if *left* is lesser than *right*
    def <(right : VideoMode) : Bool
      VoidCSFML.operator_lt_asWasW(to_unsafe, right, out result)
      return result
    end
    #
    # Overload of &gt; operator to compare video modes
    #
    # * *left* -  Left operand (a video mode)
    # * *right* - Right operand (a video mode)
    #
    # *Returns:* True if *left* is greater than *right*
    def >(right : VideoMode) : Bool
      VoidCSFML.operator_gt_asWasW(to_unsafe, right, out result)
      return result
    end
    #
    # Overload of &lt;= operator to compare video modes
    #
    # * *left* -  Left operand (a video mode)
    # * *right* - Right operand (a video mode)
    #
    # *Returns:* True if *left* is lesser or equal than *right*
    def <=(right : VideoMode) : Bool
      VoidCSFML.operator_le_asWasW(to_unsafe, right, out result)
      return result
    end
    #
    # Overload of &gt;= operator to compare video modes
    #
    # * *left* -  Left operand (a video mode)
    # * *right* - Right operand (a video mode)
    #
    # *Returns:* True if *left* is greater or equal than *right*
    def >=(right : VideoMode) : Bool
      VoidCSFML.operator_ge_asWasW(to_unsafe, right, out result)
      return result
    end
    # :nodoc:
    def to_unsafe()
      pointerof(@width).as(Void*)
    end
    # :nodoc:
    def initialize(copy : VideoMode)
      @width = uninitialized UInt32
      @height = uninitialized UInt32
      @bits_per_pixel = uninitialized UInt32
      as(Void*).copy_from(copy.as(Void*), instance_sizeof(typeof(self)))
      VoidCSFML.videomode_initialize_asW(to_unsafe, copy)
    end
    def dup() : self
      return typeof(self).new(self)
    end
  end
  #
  # Enumeration of the window styles
  @[Flags]
  enum Style
    # No border / title bar (this flag and all others are mutually exclusive)
    None = 0
    # Title bar + fixed border
    Titlebar = 1 << 0
    # Title bar + resizable border + maximize button
    Resize = 1 << 1
    # Title bar + close button
    Close = 1 << 2
    # Fullscreen mode (this flag and all others are mutually exclusive)
    Fullscreen = 1 << 3
    # Default window style
    Default = Titlebar | Resize | Close
  end
  # Window that serves as a target for OpenGL rendering
  #
  #
  #
  # `SF::Window` is the main class of the Window module. It defines
  # an OS window that is able to receive an OpenGL rendering.
  #
  # A `SF::Window` can create its own new window, or be embedded into
  # an already existing control using the create(handle) function.
  # This can be useful for embedding an OpenGL rendering area into
  # a view which is part of a bigger GUI with existing windows,
  # controls, etc. It can also serve as embedding an OpenGL rendering
  # area into a window created by another (probably richer) GUI library
  # like Qt or wxWidgets.
  #
  # The `SF::Window` class provides a simple interface for manipulating
  # the window: move, resize, show/hide, control mouse cursor, etc.
  # It also provides event handling through its pollEvent() and waitEvent()
  # functions.
  #
  # Note that OpenGL experts can pass their own parameters (antialiasing
  # level, bits for the depth and stencil buffers, etc.) to the
  # OpenGL context attached to the window, with the `SF::ContextSettings`
  # structure which is passed as an optional argument when creating the
  # window.
  #
  # Usage example:
  # ```c++
  # // Declare and create a new window
  # sf::Window window(sf::VideoMode(800, 600), "SFML window");
  #
  # // Limit the framerate to 60 frames per second (this step is optional)
  # window.setFramerateLimit(60);
  #
  # // The main loop - ends as soon as the window is closed
  # while (window.isOpen())
  # {
  #    // Event processing
  #    sf::Event event;
  #    while (window.pollEvent(event))
  #    {
  #        // Request for closing the window
  #        if (event.type == sf::Event::Closed)
  #            window.close();
  #    }
  #
  #    // Activate the window for OpenGL rendering
  #    window.setActive();
  #
  #    // OpenGL drawing commands go here...
  #
  #    // End the current frame and display its contents on screen
  #    window.display();
  # }
  # ```
  class Window
    @_window : VoidCSFML::Window_Buffer = VoidCSFML::Window_Buffer.new(0u8)
    # Default constructor
    #
    # This constructor doesn't actually create the window,
    # use the other constructors or call create() to do so.
    def initialize()
      @_window = uninitialized VoidCSFML::Window_Buffer
      VoidCSFML.window_initialize(to_unsafe)
    end
    # Construct a new window
    #
    # This constructor creates the window with the size and pixel
    # depth defined in *mode.* An optional style can be passed to
    # customize the look and behavior of the window (borders,
    # title bar, resizable, closable, ...). If *style* contains
    # Style::Fullscreen, then *mode* must be a valid video mode.
    #
    # The fourth parameter is an optional structure specifying
    # advanced OpenGL context settings such as antialiasing,
    # depth-buffer bits, etc.
    #
    # * *mode* -     Video mode to use (defines the width, height and depth of the rendering area of the window)
    # * *title* -    Title of the window
    # * *style* -    %Window style, a bitwise OR combination of `SF::Style` enumerators
    # * *settings* - Additional settings for the underlying OpenGL context
    def initialize(mode : VideoMode, title : String, style : Style = Style::Default, settings : ContextSettings = ContextSettings.new())
      @_window = uninitialized VoidCSFML::Window_Buffer
      VoidCSFML.window_initialize_wg0bQssaLFw4(to_unsafe, mode, title.size, title.chars, style, settings)
    end
    # Construct the window from an existing control
    #
    # Use this constructor if you want to create an OpenGL
    # rendering area into an already existing control.
    #
    # The second parameter is an optional structure specifying
    # advanced OpenGL context settings such as antialiasing,
    # depth-buffer bits, etc.
    #
    # * *handle* -   Platform-specific handle of the control (*hwnd* on
    #                 Windows, *%window* on Linux/FreeBSD, *ns_window* on OS X)
    # * *settings* - Additional settings for the underlying OpenGL context
    def initialize(handle : WindowHandle, settings : ContextSettings = ContextSettings.new())
      @_window = uninitialized VoidCSFML::Window_Buffer
      VoidCSFML.window_initialize_rLQFw4(to_unsafe, handle, settings)
    end
    # Destructor
    #
    # Closes the window and frees all the resources attached to it.
    def finalize()
      VoidCSFML.window_finalize(to_unsafe)
    end
    # Create (or recreate) the window
    #
    # If the window was already created, it closes it first.
    # If *style* contains Style::Fullscreen, then *mode*
    # must be a valid video mode.
    #
    # The fourth parameter is an optional structure specifying
    # advanced OpenGL context settings such as antialiasing,
    # depth-buffer bits, etc.
    #
    # * *mode* -     Video mode to use (defines the width, height and depth of the rendering area of the window)
    # * *title* -    Title of the window
    # * *style* -    %Window style, a bitwise OR combination of `SF::Style` enumerators
    # * *settings* - Additional settings for the underlying OpenGL context
    def create(mode : VideoMode, title : String, style : Style = Style::Default, settings : ContextSettings = ContextSettings.new())
      VoidCSFML.window_create_wg0bQssaLFw4(to_unsafe, mode, title.size, title.chars, style, settings)
    end
    # Shorthand for `window = Window.new; window.create(...); window`
    def self.new(mode : VideoMode, title : String, style : Style = Style::Default, settings : ContextSettings = ContextSettings.new()) : self
      obj = new
      obj.create(mode, title, style, settings)
      obj
    end
    # Create (or recreate) the window from an existing control
    #
    # Use this function if you want to create an OpenGL
    # rendering area into an already existing control.
    # If the window was already created, it closes it first.
    #
    # The second parameter is an optional structure specifying
    # advanced OpenGL context settings such as antialiasing,
    # depth-buffer bits, etc.
    #
    # * *handle* -   Platform-specific handle of the control (*hwnd* on
    #                 Windows, *%window* on Linux/FreeBSD, *ns_window* on OS X)
    # * *settings* - Additional settings for the underlying OpenGL context
    def create(handle : WindowHandle, settings : ContextSettings = ContextSettings.new())
      VoidCSFML.window_create_rLQFw4(to_unsafe, handle, settings)
    end
    # Shorthand for `window = Window.new; window.create(...); window`
    def self.new(handle : WindowHandle, settings : ContextSettings = ContextSettings.new()) : self
      obj = new
      obj.create(handle, settings)
      obj
    end
    # Close the window and destroy all the attached resources
    #
    # After calling this function, the `SF::Window` instance remains
    # valid and you can call create() to recreate the window.
    # All other functions such as pollEvent() or display() will
    # still work (i.e. you don't have to test isOpen() every time),
    # and will have no effect on closed windows.
    def close()
      VoidCSFML.window_close(to_unsafe)
    end
    # Tell whether or not the window is open
    #
    # This function returns whether or not the window exists.
    # Note that a hidden window (setVisible(false)) is open
    # (therefore this function would return true).
    #
    # *Returns:* True if the window is open, false if it has been closed
    def open?() : Bool
      VoidCSFML.window_isopen(to_unsafe, out result)
      return result
    end
    # Get the settings of the OpenGL context of the window
    #
    # Note that these settings may be different from what was
    # passed to the constructor or the create() function,
    # if one or more settings were not supported. In this case,
    # SFML chose the closest match.
    #
    # *Returns:* Structure containing the OpenGL context settings
    def settings() : ContextSettings
      result = ContextSettings.allocate
      VoidCSFML.window_getsettings(to_unsafe, result)
      return result
    end
    # Pop the event on top of the event queue, if any, and return it
    #
    # This function is not blocking: if there's no pending event then
    # it will return false and leave *event* unmodified.
    # Note that more than one event may be present in the event queue,
    # thus you should always call this function in a loop
    # to make sure that you process every pending event.
    # ```c++
    # sf::Event event;
    # while (window.pollEvent(event))
    # {
    #    // process event...
    # }
    # ```
    #
    # * *event* - Event to be returned
    #
    # *Returns:* True if an event was returned, or false if the event queue was empty
    #
    # *See also:* waitEvent
    def poll_event() : Event?
      event = uninitialized VoidCSFML::Event_Buffer
      VoidCSFML.window_pollevent_YJW(to_unsafe, event, out result)
      if result
        {% begin %}
        case event.to_unsafe.as(LibC::Int*).value
          {% for m, i in %w[Closed Resized LostFocus GainedFocus TextEntered KeyPressed KeyReleased MouseWheelMoved MouseWheelScrolled MouseButtonPressed MouseButtonReleased MouseMoved MouseEntered MouseLeft JoystickButtonPressed JoystickButtonReleased JoystickMoved JoystickConnected JoystickDisconnected TouchBegan TouchMoved TouchEnded SensorChanged] %}
        when {{i}}
          (event.to_unsafe.as(LibC::Int*) + 1).as(Event::{{m.id}}*).value
          {% end %}
        end .not_nil!
        {% end %}
      end
    end
    # Wait for an event and return it
    #
    # This function is blocking: if there's no pending event then
    # it will wait until an event is received.
    # After this function returns (and no error occurred),
    # the *event* object is always valid and filled properly.
    # This function is typically used when you have a thread that
    # is dedicated to events handling: you want to make this thread
    # sleep as long as no new event is received.
    # ```c++
    # sf::Event event;
    # if (window.waitEvent(event))
    # {
    #    // process event...
    # }
    # ```
    #
    # * *event* - Event to be returned
    #
    # *Returns:* False if any error occurred
    #
    # *See also:* pollEvent
    def wait_event() : Event?
      event = uninitialized VoidCSFML::Event_Buffer
      VoidCSFML.window_waitevent_YJW(to_unsafe, event, out result)
      if result
        {% begin %}
        case event.to_unsafe.as(LibC::Int*).value
          {% for m, i in %w[Closed Resized LostFocus GainedFocus TextEntered KeyPressed KeyReleased MouseWheelMoved MouseWheelScrolled MouseButtonPressed MouseButtonReleased MouseMoved MouseEntered MouseLeft JoystickButtonPressed JoystickButtonReleased JoystickMoved JoystickConnected JoystickDisconnected TouchBegan TouchMoved TouchEnded SensorChanged] %}
        when {{i}}
          (event.to_unsafe.as(LibC::Int*) + 1).as(Event::{{m.id}}*).value
          {% end %}
        end .not_nil!
        {% end %}
      end
    end
    # Get the position of the window
    #
    # *Returns:* Position of the window, in pixels
    #
    # *See also:* setPosition
    def position() : Vector2i
      result = Vector2i.allocate
      VoidCSFML.window_getposition(to_unsafe, result)
      return result
    end
    # Change the position of the window on screen
    #
    # This function only works for top-level windows
    # (i.e. it will be ignored for windows created from
    # the handle of a child window/control).
    #
    # * *position* - New position, in pixels
    #
    # *See also:* getPosition
    def position=(position : Vector2|Tuple)
      position = Vector2i.new(position[0].to_i32, position[1].to_i32)
      VoidCSFML.window_setposition_ufV(to_unsafe, position)
    end
    # Get the size of the rendering region of the window
    #
    # The size doesn't include the titlebar and borders
    # of the window.
    #
    # *Returns:* Size in pixels
    #
    # *See also:* setSize
    def size() : Vector2u
      result = Vector2u.allocate
      VoidCSFML.window_getsize(to_unsafe, result)
      return result
    end
    # Change the size of the rendering region of the window
    #
    # * *size* - New size, in pixels
    #
    # *See also:* getSize
    def size=(size : Vector2|Tuple)
      size = Vector2u.new(size[0].to_u32, size[1].to_u32)
      VoidCSFML.window_setsize_DXO(to_unsafe, size)
    end
    # Change the title of the window
    #
    # * *title* - New title
    #
    # *See also:* setIcon
    def title=(title : String)
      VoidCSFML.window_settitle_bQs(to_unsafe, title.size, title.chars)
    end
    # Change the window's icon
    #
    # *pixels* must be an array of *width* x *height* pixels
    # in 32-bits RGBA format.
    #
    # The OS default icon is used by default.
    #
    # * *width* -  Icon's width, in pixels
    # * *height* - Icon's height, in pixels
    # * *pixels* - Pointer to the array of pixels in memory. The
    #               pixels are copied, so you need not keep the
    #               source alive after calling this function.
    #
    # *See also:* setTitle
    def set_icon(width : Int, height : Int, pixels : UInt8*)
      VoidCSFML.window_seticon_emSemS843(to_unsafe, LibC::UInt.new(width), LibC::UInt.new(height), pixels)
    end
    # Show or hide the window
    #
    # The window is shown by default.
    #
    # * *visible* - True to show the window, false to hide it
    def visible=(visible : Bool)
      VoidCSFML.window_setvisible_GZq(to_unsafe, visible)
    end
    # Enable or disable vertical synchronization
    #
    # Activating vertical synchronization will limit the number
    # of frames displayed to the refresh rate of the monitor.
    # This can avoid some visual artifacts, and limit the framerate
    # to a good value (but not constant across different computers).
    #
    # Vertical synchronization is disabled by default.
    #
    # * *enabled* - True to enable v-sync, false to deactivate it
    def vertical_sync_enabled=(enabled : Bool)
      VoidCSFML.window_setverticalsyncenabled_GZq(to_unsafe, enabled)
    end
    # Show or hide the mouse cursor
    #
    # The mouse cursor is visible by default.
    #
    # * *visible* - True to show the mouse cursor, false to hide it
    def mouse_cursor_visible=(visible : Bool)
      VoidCSFML.window_setmousecursorvisible_GZq(to_unsafe, visible)
    end
    # Enable or disable automatic key-repeat
    #
    # If key repeat is enabled, you will receive repeated
    # KeyPressed events while keeping a key pressed. If it is disabled,
    # you will only get a single event when the key is pressed.
    #
    # Key repeat is enabled by default.
    #
    # * *enabled* - True to enable, false to disable
    def key_repeat_enabled=(enabled : Bool)
      VoidCSFML.window_setkeyrepeatenabled_GZq(to_unsafe, enabled)
    end
    # Limit the framerate to a maximum fixed frequency
    #
    # If a limit is set, the window will use a small delay after
    # each call to display() to ensure that the current frame
    # lasted long enough to match the framerate limit.
    # SFML will try to match the given limit as much as it can,
    # but since it internally uses `SF::sleep`, whose precision
    # depends on the underlying OS, the results may be a little
    # unprecise as well (for example, you can get 65 FPS when
    # requesting 60).
    #
    # * *limit* - Framerate limit, in frames per seconds (use 0 to disable limit)
    def framerate_limit=(limit : Int)
      VoidCSFML.window_setframeratelimit_emS(to_unsafe, LibC::UInt.new(limit))
    end
    # Change the joystick threshold
    #
    # The joystick threshold is the value below which
    # no JoystickMoved event will be generated.
    #
    # The threshold value is 0.1 by default.
    #
    # * *threshold* - New threshold, in the range [0, 100]
    def joystick_threshold=(threshold : Number)
      VoidCSFML.window_setjoystickthreshold_Bw9(to_unsafe, LibC::Float.new(threshold))
    end
    # Activate or deactivate the window as the current target
    #        for OpenGL rendering
    #
    # A window is active only on the current thread, if you want to
    # make it active on another thread you have to deactivate it
    # on the previous thread first if it was active.
    # Only one window can be active on a thread at a time, thus
    # the window previously active (if any) automatically gets deactivated.
    # This is not to be confused with requestFocus().
    #
    # * *active* - True to activate, false to deactivate
    #
    # *Returns:* True if operation was successful, false otherwise
    def active=(active : Bool = true) : Bool
      VoidCSFML.window_setactive_GZq(to_unsafe, active, out result)
      return result
    end
    # Request the current window to be made the active
    #        foreground window
    #
    # At any given time, only one window may have the input focus
    # to receive input events such as keystrokes or mouse events.
    # If a window requests focus, it only hints to the operating
    # system, that it would like to be focused. The operating system
    # is free to deny the request.
    # This is not to be confused with setActive().
    #
    # *See also:* hasFocus
    def request_focus()
      VoidCSFML.window_requestfocus(to_unsafe)
    end
    # Check whether the window has the input focus
    #
    # At any given time, only one window may have the input focus
    # to receive input events such as keystrokes or most mouse
    # events.
    #
    # *Returns:* True if window has focus, false otherwise
    # *See also:* requestFocus
    def focus?() : Bool
      VoidCSFML.window_hasfocus(to_unsafe, out result)
      return result
    end
    # Display on screen what has been rendered to the window so far
    #
    # This function is typically called after all OpenGL rendering
    # has been done for the current frame, in order to show
    # it on screen.
    def display()
      VoidCSFML.window_display(to_unsafe)
    end
    # Get the OS-specific handle of the window
    #
    # The type of the returned handle is `SF::WindowHandle`,
    # which is a typedef to the handle type defined by the OS.
    # You shouldn't need to use this function, unless you have
    # very specific stuff to implement that SFML doesn't support,
    # or implement a temporary workaround until a bug is fixed.
    # The type is *hwnd* on Windows, *%window* on Linux/FreeBSD
    # and *ns_window* on OS X.
    #
    # *Returns:* System handle of the window
    def system_handle() : WindowHandle
      VoidCSFML.window_getsystemhandle(to_unsafe, out result)
      return result
    end
    include GlResource
    include NonCopyable
    # :nodoc:
    def to_unsafe()
      pointerof(@_window).as(Void*)
    end
    # :nodoc:
    def inspect(io)
      to_s(io)
    end
  end
  VoidCSFML.sfml_window_version(out major, out minor, out patch)
  if SFML_VERSION != (ver = "#{major}.#{minor}.#{patch}")
    STDERR.puts "Warning: CrSFML was built for SFML #{SFML_VERSION}, found SFML #{ver}"
  end
end
