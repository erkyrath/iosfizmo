/* fizmo-config.h: Header file for Fizmo configuration when building the IosFizmo project.
 
	In the Unix Fizmo distribution, build configuration comes from Makefiles all down the build tree, which are in turn controlled by a top-level "config.mk" file. The iOS project (Xcode) does not use Makefiles. Instead, this header file supplies all the necessary #defines. (This header is included from the project's IosFizmo-Prefix.pch file.)
 */

#define DISABLE_BABEL 1
