#This scripts will add all the cpp and h files under src and include folders, and
#assumes that your Ogre source code is in Dependencies/Ogre and that:
# In Windows you built Ogre into Dependencies/Ogre/build
# In Linux you built Release into Dependencies/Ogre/build/Release
# In Linux you built Debug into Dependencies/Ogre/build/Debug
#
# If your source code is not at "Dependencies/Ogre"; you can use "mklink /D" to create
# a symbolic link to where the source code is located on Windows.
# On Linux, you can use "ln -s"

#set( CMAKE_TOOLCHAIN_FILE CMake/iOS.cmake )

cmake_minimum_required( VERSION 3.5.1 )
project( Engine_Ogre_Next)

set( EXECUTABLE_OUTPUT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/bin/${CMAKE_BUILD_TYPE}" )

include( CMake/Bootstrap.cmake )
include( CMake/Dependencies/OGRE.cmake )

if( APPLE )
	set( CMAKE_CXX_STANDARD 11 )
endif()

setupOgre( OGRE_SOURCE, OGRE_BINARIES, OGRE_LIBRARIES, FALSE, FALSE, FALSE )

# Setup our application
set( EXECUTABLE_OUTPUT_PATH "${CMAKE_CURRENT_SOURCE_DIR}/bin/${CMAKE_BUILD_TYPE}" )
if( MSVC )
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")
	if( NOT PLATFORM_X64 )
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:SSE2")
	endif()
	add_definitions( -DUNICODE -D_UNICODE )
endif()

if( APPLE )
	macro( add_recursive dir retVal )
		file( GLOB_RECURSE ${retVal} ${dir}/*.h ${dir}/*.cpp ${dir}/*.c ${dir}/*.mm ${dir}/*.m )
	endmacro()
else()
	macro( add_recursive dir retVal )
		file( GLOB_RECURSE ${retVal} ${dir}/*.h ${dir}/*.cpp ${dir}/*.c )
	endmacro()
endif()

include_directories( "./include" )
# Ogre doesn't need this include, but we do because of Rapidjson in UnitTesting.cpp
include_directories( "./Dependencies/Ogre/Dependencies/include" )

add_recursive( ./src SOURCES )
add_recursive( ./include HEADERS )

if( APPLE )
	if( APPLE_IOS )
		file( GLOB_RECURSE RESOURCES ./src/*.storyboard )
	endif()
	set( RESOURCES ${RESOURCES}
		${CMAKE_CURRENT_SOURCE_DIR}/bin/Data )

	if( APPLE_IOS )
		set_source_files_properties(
			${CMAKE_CURRENT_SOURCE_DIR}/src/OgreCommon/System/OSX/OSXUtils.mm
			PROPERTIES HEADER_FILE_ONLY TRUE
		)
	else()
		set_source_files_properties(
			${CMAKE_CURRENT_SOURCE_DIR}/src/OgreCommon/System/iOS/AppDelegate.mm
			${CMAKE_CURRENT_SOURCE_DIR}/src/OgreCommon/System/iOS/GameViewController.mm
			${CMAKE_CURRENT_SOURCE_DIR}/src/OgreCommon/System/iOS/iOSUtils.mm
			PROPERTIES HEADER_FILE_ONLY TRUE
		)
	endif()
endif()

if( APPLE )
	# Treat our *.c & *.cpp files as *.mm + Enable ARC on them
	set_source_files_properties( ${SOURCES} PROPERTIES
		COMPILE_FLAGS
			"-x objective-c++ -fobjc-arc"
	)
endif()

add_executable( ${PROJECT_NAME} WIN32 MACOSX_BUNDLE ${SOURCES} ${HEADERS} ${RESOURCES} )
set_target_properties(${PROJECT_NAME} PROPERTIES 
	VS_DEBUGGER_WORKING_DIRECTORY "$<TARGET_FILE_DIR:${PROJECT_NAME}>"
	CXX_STANDARD 17
	CXX_STANDARD_REQUIRED ON
)
target_link_libraries( ${PROJECT_NAME} ${OGRE_LIBRARIES})

if( APPLE )
	set_target_properties( ${PROJECT_NAME} PROPERTIES XCODE_ATTRIBUTE_ENABLE_BITCODE "NO" )
	set_target_properties( ${PROJECT_NAME} PROPERTIES RESOURCE "${RESOURCES}" )
	#set_target_properties( ${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_ICON_FILE SampleBrowser_OSX.icns)
	set( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} \
		-framework CoreGraphics -framework QuartzCore -framework Metal  -framework StoreKit" )

	if( APPLE_IOS )
		# iPhone
		set( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} \
			-framework UIKit -framework CoreText -framework CoreMotion" )

		# These must be global for all projects; or else they'll cause
		# trouble or increased compiling times
		set( CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "10.0" )
		set( CMAKE_XCODE_ATTRIBUTE_VALID_ARCHS "arm64" )

		set_target_properties( ${PROJECT_NAME} PROPERTIES
			MACOSX_BUNDLE_INFO_PLIST
				${CMAKE_CURRENT_SOURCE_DIR}/Scripts/Apple/iPhone/iOSApp.plist
			# XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS
			#	"${CMAKE_CURRENT_SOURCE_DIR}/Scripts/Apple/iPhone/iOSEntitlements.plist"
		)
	else()
		# macOS
		set( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -framework Foundation" )
		set_target_properties( ${PROJECT_NAME} PROPERTIES
			MACOSX_BUNDLE_INFO_PLIST
				${CMAKE_CURRENT_SOURCE_DIR}/Scripts/Apple/macOS/macOSApp.plist
			# XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS
			#	"${CMAKE_CURRENT_SOURCE_DIR}/Scripts/Apple/macOS/macOSEntitlements.plist"
		)
	endif()
endif()

set( SDL2_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Dependencies/SDL2/include" )
set( SDL2_LIBRARY "${CMAKE_CURRENT_SOURCE_DIR}/Dependencies/SDL2/lib/x64/SDL2.lib" )
set( SDL2MAIN_LIBRARY "${CMAKE_CURRENT_SOURCE_DIR}/Dependencies/SDL2/lib/x64/SDL2main.lib" )

# set(BULLET3_BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/bullet3-master")
# set(BULLET3_INCLUDE_DIR "${BULLET3_BASE_DIR}/src")
# set(BULLET3_LIB_DIR "${BULLET3_BASE_DIR}/build/lib")

# set(BULLET_DYNAMICS_LIBRARY "${BULLET3_LIB_DIR}/$<IF:$<CONFIG:Debug>,Debug/BulletDynamics_Debug.lib,Release/BulletDynamics.lib>")
# set(BULLET_COLLISION_LIBRARY "${BULLET3_LIB_DIR}/$<IF:$<CONFIG:Debug>,Debug/BulletCollision_Debug.lib,Release/BulletCollision.lib>")
# set(LINEAR_MATH_LIBRARY "${BULLET3_LIB_DIR}/$<IF:$<CONFIG:Debug>,Debug/LinearMath_Debug.lib,Release/LinearMath.lib>")

target_include_directories(${PROJECT_NAME} PRIVATE 
	${SDL2_INCLUDE_DIR}
	# ${BULLET3_INCLUDE_DIR}
)
target_link_libraries(${PROJECT_NAME} 
	${SDL2_LIBRARY} 
	${SDL2MAIN_LIBRARY}
	# ${BULLET_DYNAMICS_LIBRARY}
	# ${BULLET_COLLISION_LIBRARY}
	# ${LINEAR_MATH_LIBRARY}
)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/Dependencies/SDL2/lib/x64/SDL2.dll"
        "$<TARGET_FILE_DIR:${PROJECT_NAME}>/SDL2.dll"
    COMMENT "Copying SDL2.dll to output directory"
)

add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CMAKE_CURRENT_SOURCE_DIR}/Assets"
        "$<TARGET_FILE_DIR:${PROJECT_NAME}>/../Data/Assets"
	COMMENT "Copying Assets to output directory"
)

# Après add_recursive
source_group("Header Files\\OgreCommon" REGULAR_EXPRESSION "include/OgreCommon/.*\\.h")
source_group("Header Files\\Game" REGULAR_EXPRESSION "include/Game/.*\\.h")
source_group("Source Files\\OgreCommon" REGULAR_EXPRESSION "src/OgreCommon/.*\\.cpp")
source_group("Source Files\\Game" REGULAR_EXPRESSION "src/Game/.*\\.cpp")