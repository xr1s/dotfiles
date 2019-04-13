import itertools
import os
import shlex
import subprocess
import ycm_core


C_BASE_FLAGS = ['-xc', '-Wall', '-Wextra', '-std=c11']
CXX_BASE_FLAGS = ['-xc++', '-std=c++2a', '-Wall', '-Wextra']
C_SOURCE_EXTENSIONS = ['.c']
CXX_SOURCE_EXTENSIONS = ['.cc', '.cxx', '.cpp', '.m', '.mm']
HEADER_EXTENSIONS = ['.h', '.hxx', '.hpp', '.hh']

SOURCE_DIRECTORIES = ['src', 'lib']
HEADER_DIRECTORIES = ['include']
BUILD_DIRECTORY = 'bin'


def CollectHeaderPath(lang):
    cmd = ['gcc', '-E', '-v', '-x' + lang, '-']
    info = subprocess.Popen(cmd, stderr=subprocess.PIPE)
    args = info.stderr.read().decode().splitlines()
    fst = args.index('#include "..." search starts here:')
    snd = args.index('#include <...> search starts here:')
    end = args.index('End of search list.')
    include = []
    for header in args[fst + 1:snd] + args[snd + 1:end]:
        if header.endswith('(framework directory)'):
            header = header[:-22]
        include.extend(['-isystem', header.strip()])
    if lang == 'c':
        include.extend(shlex.split(os.environ.get('CFLAGS', '')))
    if lang == 'c++':
        include.extend(shlex.split(os.environ.get('CXXFLAGS', '')))
    return include


def IsSourceFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in C_SOURCE_EXTENSIONS + CXX_SOURCE_EXTENSIONS


def IsHeaderFile(filename):
    extension = os.path.splitext(filename)[1]
    return extension in HEADER_EXTENSIONS


def FindCorrespondCompilationInfo(database, basename, extension):
    # Get info from the source files by replacing the extension.
    replacement = basename + extension
    if os.path.exists(replacement):
        compilation_info = database.GetCompilationInfoForFile(replacement)
        if compilation_info.compiler_flags_:
            return compilation_info
    # Get info from the source files by replacing the path.
    for header_dir in HEADER_DIRECTORIES:
        for source_dir in SOURCE_DIRECTORIES:
            src_file = replacement.replace(header_dir, source_dir)
            if os.path.exists(src_file):
                compilation_info = database.GetCompilationInfoForFile(src_file)
                if compilation_info.compiler_flags_:
                    return compilation_info


def GetCompilationInfoForFile(database, filename):
    if IsHeaderFile(filename):
        basename = os.path.splitext(filename)[0]
        for extension in C_SOURCE_EXTENSIONS + CXX_SOURCE_EXTENSIONS:
            return FindCorrespondCompilationInfo(database, basename, extension)
        return None
    return database.GetCompilationInfoForFile(filename)


def FindNearest(path, target, build_folder=None):
    candidate = os.path.join(path, target)
    if os.path.isfile(candidate) or os.path.isdir(candidate):
        return candidate
    parent = os.path.dirname(os.path.abspath(path))
    if parent == path:
        raise RuntimeError('Could not find ' + target)
    if build_folder:
        candidate = os.path.join(parent, build_folder, target)
        if os.path.isfile(candidate) or os.path.isdir(candidate):
            return candidate
    return FindNearest(parent, target, build_folder)


def MakeRelativePathsInFlagsAbsolute(flags, working_directory):
    if not working_directory:
        return list(flags)
    new_flags = []
    make_next_absolute = False
    path_flags = ['-isystem', '-I', '-iquote', '--sysroot=']
    for flag in flags:
        new_flag = flag
        if make_next_absolute:
            make_next_absolute = False
            if not flag.startswith('/'):
                new_flag = os.path.join(working_directory, flag)
        for path_flag in path_flags:
            if flag == path_flag:
                make_next_absolute = True
                break
            if flag.startswith(path_flag):
                path = flag[len(path_flag):]
                new_flag = path_flag + os.path.join(working_directory, path)
                break

        if new_flag:
            new_flags.append(new_flag)
    return new_flags


def FlagsForClangComplete(root):
    try:
        clang_complete_path = FindNearest(root, '.clang_complete')
        clang_complete_flags = open(clang_complete_path).read().splitlines()
        return clang_complete_flags
    except Exception:
        return None


def FlagsForInclude(root):
    try:
        flags = []
        include_path = FindNearest(root, 'include')
        for dirroot, dirnames, filenames in os.walk(include_path):
            for dir_path in dirnames:
                real_path = os.path.join(dirroot, dir_path)
                flags = flags + ['-I' + real_path]
        return flags
    except Exception:
        return None


def FlagsForCompilationDatabase(root, filename):
    try:
        # Last argument of next function is the name of the build folder for
        # out of source projects
        compilation_db_path = FindNearest(
            root, 'compile_commands.json', BUILD_DIRECTORY
        )
        compilation_db_dir = os.path.dirname(compilation_db_path)
        compilation_db = ycm_core.CompilationDatabase(compilation_db_dir)
        if not compilation_db:
            return None
        compilation_info = GetCompilationInfoForFile(compilation_db, filename)
        if not compilation_info:
            return None
        return MakeRelativePathsInFlagsAbsolute(
            compilation_info.compiler_flags_,
            compilation_info.compiler_working_dir_
        )
    except Exception:
        return None


def FlagsForFile(filename):
    root = os.path.realpath(filename)
    compilation_db_flags = FlagsForCompilationDatabase(root, filename)
    if compilation_db_flags:
        final_flags = compilation_db_flags
    else:
        extension = os.path.splitext(filename)[1]
        if extension in C_SOURCE_EXTENSIONS:
            final_flags = C_BASE_FLAGS + CollectHeaderPath('c')
        else:
            final_flags = CXX_BASE_FLAGS + CollectHeaderPath('c++')

        clang_flags = FlagsForClangComplete(root)
        if clang_flags:
            final_flags.extend(clang_flags)
        include_flags = FlagsForInclude(root)
        if include_flags:
            final_flags.extend(include_flags)
    return {'flags': final_flags, 'do_cache': True}
