<<<<<<< HEAD
# RCO Animations - RedM Animation & Scenario Viewer

A highly developed and configurable animation and scenario testing tool for RedM servers. This resource provides a comprehensive interface for viewing, testing, and copying all conditional animations and scenarios available in RedM.

## Features

### 🎭 **Complete Scenario Database**
- Access to all conditional scenarios present in RedM
- Comprehensive database of scenarios with conditional animations
- Real-time scenario testing with visual feedback
- Manual animation input for testing custom animations

### 👥 **Smart Ped Generation**
- Automatically generates appropriate ped models based on scenario conditions
- Supports both male and female ped models
- Creates both peds side by side when scenario supports both genders
- Dynamic ped creation for different scenario types (human, animal)

### 🎯 **Advanced Scenario Testing**
- Test scenarios with conditional animations
- Visual representation of how scenarios look with different ped types
- Real-time scenario application and testing
- Automatic gender detection for scenarios

### 📋 **Copy & Paste Functionality**
- One-click scenario copying for easy implementation
- Copy specific scenario names for use in your scripts
### ⚙️ **Highly Configurable**
- Customizable ped models for testing
- Configurable command name
- Admin-only access control
- Flexible permission system integration

### 🎨 **Modern User Interface**
- Clean and intuitive web-based interface
- Responsive design for optimal user experience
- Easy navigation through scenarios
- Search functionality for quick scenario finding
- Manual animation input interface

## Installation

1. **Download** the resource to your server's resources folder
2. **Add** the resource to your `server.cfg`:
   ```
   ensure rco-animations
   ```
3. **Configure** the settings in `config.lua` according to your needs
4. **Restart** your server

## Configuration

### Basic Configuration
```lua
-- Ped models for testing
Config.MalePed = 'U_M_M_ARMGENERALSTOREOWNER_01'
Config.FemalePed = 'U_F_M_TUMGENERALSTOREOWNER_01'

-- Command to open the interface
Config.Command = 'animtest'

-- Admin access control
Config.AdminOnly = true
Config.AdminGroup = 'admin'
```

### Available Configuration Options
- **Ped Models**: Customize which ped models to use for testing
- **Command Name**: Set your preferred command to open the interface
- **Admin Control**: Enable/disable admin-only access
- **Permission Groups**: Configure which admin group can access the tool

## Usage

### Opening the Interface
Use the configured command (default: `/animtest`) to open the animation viewer interface.

### Testing Scenarios
1. **Browse** through the available scenarios
2. **Select** a scenario to test
3. **Choose** the appropriate ped type (male/female)
4. **Apply** the scenario to see it in action
5. **Copy** the scenario name for use in your scripts

### Testing Animations
1. **Input** custom animation dictionary and name
2. **Test** animations on different ped types
3. **Preview** how animations look in-game
4. **Apply** animations to test peds

## Features for Developers

### Scenario Database
- Complete access to all RedM scenarios
- Conditional animation support
- Automatic gender detection
- Animal scenario support

### Integration Ready
- Easy scenario name copying
- Standardized scenario format
- Compatible with most RedM frameworks
- Ready for script integration

### Performance Optimized
- Efficient scenario loading
- Optimized ped generation
- Minimal server impact
- Fast interface response

## Technical Details

### Supported Scenario Types
- **Human Scenarios**: Standard ped-based scenarios
- **Animal Scenarios**: Wildlife and domesticated animal scenarios
- **Conditional Scenarios**: Scenarios with gender-specific animations
- **Dual Gender Scenarios**: Automatically creates both male and female peds side by side

### Framework Compatibility
- **RSG Framework**: Full integration with RSG Core
- **Permission System**: Compatible with RSG permission system
- **Event System**: Uses standard RedM event system
- **NUI Interface**: Modern web-based user interface

## Requirements

- **RedM Server** (latest version recommended)
- **RSG Framework** (for admin permissions)
- **Modern Web Browser** (for interface display)

## Support

This tool is designed to be highly reliable and user-friendly. For support or feature requests, please refer to the resource documentation or contact the development team.

## License

This resource is provided as-is for use on RedM servers. Please respect the original author's work and do not redistribute without permission.

---

**RCO Animations** - Making RedM development easier, one animation at a time. 
=======
# rco-animations
A Dev tool to visualize scenarios and animations
>>>>>>> a790ed413832557a616215c36f3f1cdf6c941c3e
