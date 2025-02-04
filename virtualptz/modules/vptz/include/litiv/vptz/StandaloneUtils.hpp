#pragma once

//
//         -- Below are code snippets taken from the LITIV framework --
//
// Copyright 2015 Pierre-Luc St-Charles; visit https://github.com/plstcharles/litiv
// for the full version and licensing information (provided under Apache 2.0 terms)
//

#ifndef __CMAKE_VAR_DEF_DROP_IN__
#define __CMAKE_VAR_DEF_DROP_IN__
// required for cmake cached variable drop-in
#define ON        1
#define TRUE      1
#define OFF       0
#define FALSE     0
#endif //__CMAKE_VAR_DEF_DROP_IN__

#define XSTR_CONCAT(s1,s2) XSTR_CONCAT_BASE(s1,s2)
#define XSTR_CONCAT_BASE(s1,s2) s1##s2
#define XSTR(s) XSTR_BASE(s)
#define XSTR_BASE(s) #s

#define TIMER_TIC(x) int64 XSTR_CONCAT(__nCPUTimerTick_,x) = cv::getTickCount()
#define TIMER_TOC(x) int64 XSTR_CONCAT(__nCPUTimerVal_,x) = cv::getTickCount()-XSTR_CONCAT(__nCPUTimerTick_,x)
#define TIMER_ELAPSED_MS(x) (double(XSTR_CONCAT(__nCPUTimerVal_,x))/(cv::getTickFrequency()/1000))

#if defined(_MSC_VER)
#define __PRETTY_FUNCTION__ __FUNCSIG__
#define _USE_MATH_DEFINES
#if (defined(VPTZ_EXPORT) && defined(VPTZ_IMPORT))
#error "API Lib import/export config error"
#endif //(defined(VPTZ_EXPORT) && defined(VPTZ_IMPORT))
#if defined(VPTZ_EXPORT)
#define VPTZ_API __declspec(dllexport)
#elif defined(VPTZ_IMPORT)
#define VPTZ_API __declspec(dllimport)
#else //ndef(VPTZ_...)
#define VPTZ_API
#endif //ndef(VPTZ_...)
#else //ndef(_MSC_VER)
#define VPTZ_API
#endif //ndef(_MSC_VER)

#define VPTZ_STANDALONE_VERSION       0.3.7
#define VPTZ_STANDALONE_VERSION_STR   XSTR(LITIV_FRAMEWORK_VERSION)
#define VPTZ_STANDALONE_VERSION_MAJOR 0
#define VPTZ_STANDALONE_VERSION_MINOR 3
#define VPTZ_STANDALONE_VERSION_PATCH 7
#define VPTZ_STANDALONE_VERSION_SHA1  "GITDIR-NOTFOUND"

#define HAVE_GLSL           1
#define HAVE_GLFW           1
#define HAVE_FREEGLUT       0

#include <cmath>
#include <mutex>
#include <vector>
#include <thread>
#include <chrono>
#include <atomic>
#include <future>
#include <iostream>
#include <functional>
#include <type_traits>
#include <condition_variable>
#include <opencv2/core.hpp>

#define D2R(d) ((d)*(M_PI/180.0))
#define R2D(r) ((r)*(180.0/M_PI))
#define isnan(f) std::isnan(f)

#include <GL/glew.h>
#if HAVE_GLFW
#include <GLFW/glfw3.h>
struct glfwWindowDeleter {
    void operator()(GLFWwindow* pWindow) {
        glfwDestroyWindow(pWindow);
    }
};
#endif //HAVE_GLFW
#if HAVE_FREEGLUT
#include <GL/freeglut.h>
struct glutHandle {
    glutHandle() : m_nHandle(0) {}
    glutHandle(std::nullptr_t) : m_nHandle(0) {}
    explicit glutHandle(int v) : m_nHandle(v) {}
    glutHandle& operator=(std::nullptr_t) {m_nHandle = 0; return *this;}
    explicit operator bool() const {return m_nHandle!=0;}
    int m_nHandle;
};
inline bool operator==(const glutHandle& lhs, const glutHandle& rhs) {return lhs.m_nHandle==rhs.m_nHandle;}
inline bool operator!=(const glutHandle& lhs, const glutHandle& rhs) {return lhs.m_nHandle!=rhs.m_nHandle;}
struct glutWindowDeleter {
    void operator()(const glutHandle& oWindowHandle) {
        glutDestroyWindow(oWindowHandle.m_nHandle);
    }
    typedef glutHandle pointer;
};
#endif //HAVE_FREEGLUT

namespace CxxUtils {

    template<char... str> struct MetaStr {
        static constexpr char value[] = {str...};
    };
    template<char... str>
    constexpr char MetaStr<str...>::value[];

    template<typename, typename>
    struct MetaStrConcat;
    template<char... str1, char... str2>
    struct MetaStrConcat<MetaStr<str1...>, MetaStr<str2...>> {
        using type = MetaStr<str1..., str2...>;
    };

    template<typename...>
    struct MetaStrConcatenator;
    template<>
    struct MetaStrConcatenator<> {
        using type = MetaStr<>;
    };
    template<typename str, typename... vstr>
    struct MetaStrConcatenator<str, vstr...> {
        using type = typename MetaStrConcat<str, typename MetaStrConcatenator<vstr...>::type>::type;
    };

    template<size_t N>
    struct MetaITOA {
        using type = typename MetaStrConcat<typename std::conditional<(N>=10),typename MetaITOA<(N/10)>::type,MetaStr<>>::type,MetaStr<'0'+(N%10)>>::type;
    };
    template<>
    struct MetaITOA<0> {
        using type = MetaStr<'0'>;
    };

    struct UncaughtExceptionLogger {
        UncaughtExceptionLogger(const char* sFunc, const char* sFile, int nLine) :
                m_sMsg(cv::format("Unwinding at function '%s' from %s(%d) due to uncaught exception\n",sFunc,sFile,nLine)) {}
        const std::string m_sMsg;
        ~UncaughtExceptionLogger() {
            if(std::uncaught_exception())
                std::cerr << m_sMsg;
        }
    };

} //namespace CxxUtils

#define TARGET_GL_VER_MAJOR  3
#define TARGET_GL_VER_MINOR  0
#define GLEW_EXPERIMENTAL    1

#define glError(msg) throw GLException(msg,__PRETTY_FUNCTION__,__FILE__,__LINE__)
#define glErrorExt(msg,...) throw GLException(msg,__PRETTY_FUNCTION__,__FILE__,__LINE__,__VA_ARGS__)
#define glAssert(expr) {if(!!(expr)); else glError("assertion failed ("#expr")");}
#define glErrorCheck { \
    GLenum __errn = glGetError(); \
    if(__errn!=GL_NO_ERROR) \
        glErrorExt("glErrorCheck failed [code=%d, msg=%s]",__errn,gluErrorString(__errn)); \
}
#ifdef _DEBUG
#define glDbgAssert(expr) glAssert(expr)
#define glDbgErrorCheck glErrorCheck
#define glDbgExceptionWatch CxxUtils::UncaughtExceptionLogger __logger(__PRETTY_FUNCTION__,__FILE__,__LINE__)
#else //!defined(_DEBUG)
#define glDbgAssert(expr)
#define glDbgErrorCheck
#define glDbgExceptionWatch
#endif //!defined(_DEBUG)

struct GLException : public std::runtime_error {
    template<typename... VALIST>
    GLException(const char* sErrMsg, const char* sFunc, const char* sFile, int nLine, VALIST... vArgs) :
            std::runtime_error(cv::format((std::string("GLException in function '%s' from %s(%d) : \n")+sErrMsg).c_str(),sFunc,sFile,nLine,vArgs...)),
            m_acErrMsg(sErrMsg),
            m_acFuncName(sFunc),
            m_acFileName(sFile),
            m_nLineNumber(nLine) {}
    const char* const m_acErrMsg;
    const char* const m_acFuncName;
    const char* const m_acFileName;
    const int m_nLineNumber;
};

template<size_t nGLVerMajor=TARGET_GL_VER_MAJOR,size_t nGLVerMinor=TARGET_GL_VER_MINOR>
class GLContext {
public:
    GLContext(const cv::Size& oWinSize, const std::string& sWinName, bool bHide=true) {
#if HAVE_GLFW
        std::call_once(GetInitFlag(),[](){
            if(glfwInit()==GL_FALSE)
                glError("Failed to init GLFW");
            std::atexit(glfwTerminate);
        });
        if(nGLVerMajor>3 || (nGLVerMajor==3 && nGLVerMinor>=2))
            glfwWindowHint(GLFW_OPENGL_PROFILE,GLFW_OPENGL_CORE_PROFILE);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR,nGLVerMajor);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR,nGLVerMinor);
        glfwWindowHint(GLFW_RESIZABLE,GL_FALSE);
        if(bHide)
            glfwWindowHint(GLFW_VISIBLE,GL_FALSE);
        m_pWindowHandle = std::unique_ptr<GLFWwindow,glfwWindowDeleter>(glfwCreateWindow(oWinSize.width,oWinSize.height,sWinName.c_str(),nullptr,nullptr),glfwWindowDeleter());
        if(!m_pWindowHandle.get())
            glErrorExt("Failed to create [%d,%d] window via GLFW for core GL profile v%d.%d",oWinSize.width,oWinSize.height,nGLVerMajor,nGLVerMinor);
        glfwMakeContextCurrent(m_pWindowHandle.get());
#elif HAVE_FREEGLUT
        std::call_once(GetInitFlag(),[](){
            int argc = 0;
            glutInit(&argc,NULL);
        });
        glutInitDisplayMode(GLUT_SINGLE);
        glutInitWindowSize(oWinSize.width,oWinSize.height);
        glutInitWindowPosition(0,0);
        m_oWindowHandle = std::unique_ptr<glutHandle,glutWindowDeleter>(glutHandle(glutCreateWindow(sWinName.c_str())),glutWindowDeleter());
        if(!(m_oWindowHandle.get().m_nHandle))
            glError("Failed to create window via glut");
        glutSetWindow(m_oWindowHandle.get().m_nHandle);
        if(bHide)
            glutHideWindow();
#endif //HAVE_FREEGLUT
        glErrorCheck;
        glewInitErrorCheck();
    }

    void SetAsActive() {
#if HAVE_GLFW
        glfwMakeContextCurrent(m_pWindowHandle.get());
#elif HAVE_FREEGLUT
        glutSetWindow(m_oWindowHandle.get().m_nHandle);
#endif //HAVE_FREEGLUT
    }

    constexpr static std::string GetGLEWVersionString() {return std::string("GL_VERSION_")+CxxUtils::MetaStrConcatenator<typename CxxUtils::MetaITOA<nGLVerMajor>::type,CxxUtils::MetaStr<'_'>,typename CxxUtils::MetaITOA<nGLVerMinor>::type,CxxUtils::MetaStr<'\0'>>::type::value;}

private:

    void glewInitErrorCheck() {
        glErrorCheck;
        glewExperimental = GLEW_EXPERIMENTAL?GL_TRUE:GL_FALSE;
        if(GLenum glewerrn=glewInit()!=GLEW_OK)
            glErrorExt("Failed to init GLEW [code=%d, msg=%s]",glewerrn,glewGetErrorString(glewerrn));
        GLenum errn = glGetError();
        // see glew init GL_INVALID_ENUM bug discussion at https://www.opengl.org/wiki/OpenGL_Loading_Library
        if(errn!=GL_NO_ERROR && errn!=GL_INVALID_ENUM && errn!=1)
            glErrorExt("Unexpected GLEW init error [code=%d, msg=%s]",errn,gluErrorString(errn));
        if(!glewIsSupported(GetGLEWVersionString().c_str()))
            glErrorExt("Bad GL core/ext version detected (target is %s)",GetGLEWVersionString().c_str());
    }

#if HAVE_GLFW
    std::unique_ptr<GLFWwindow,glfwWindowDeleter> m_pWindowHandle;
#elif HAVE_FREEGLUT
    std::unique_ptr<glutHandle,glutWindowDeleter> m_oWindowHandle;
#endif //HAVE_FREEGLUT
    GLContext& operator=(const GLContext&) = delete;
    GLContext(const GLContext&) = delete;
    static std::once_flag& GetInitFlag() {static std::once_flag oInitFlag; return oInitFlag;}
};
using GLDefaultContext = GLContext<>;
