cmake_minimum_required(VERSION 3.20)
project(nebula-shell VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Widgets
    WaylandCompositor
    Svg
    DBus
    Multimedia
)

# Sources
set(SOURCES
    src/main.cpp
    src/shellcontroller.cpp
    src/windowmanager.cpp
    src/notificationserver.cpp
    src/settingsmanager.cpp
    src/themeengine.cpp
    src/searchprovider.cpp
    src/virtualdesktopmanager.cpp
    src/powercontroller.cpp
)

set(HEADERS
    src/shellcontroller.h
    src/windowmanager.h
    src/notificationserver.h
    src/settingsmanager.h
    src/themeengine.h
    src/searchprovider.h
    src/virtualdesktopmanager.h
    src/powercontroller.h
)

# QML resources
qt6_add_resources(QML_RESOURCES
    qml/qml.qrc
)

add_executable(nebula-shell
    ${SOURCES}
    ${HEADERS}
    ${QML_RESOURCES}
)

target_link_libraries(nebula-shell PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Widgets
    Qt6::WaylandCompositor
    Qt6::Svg
    Qt6::DBus
    Qt6::Multimedia
)

install(TARGETS nebula-shell DESTINATION bin)
install(DIRECTORY qml/ DESTINATION share/nebula-desktop/qml)
