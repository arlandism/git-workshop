class Repository

  DELETE_FLAG = :D

  attr_reader :name, :commits,
              :staged, :unstaged,
              :untracked,
              :modified_files,
              :tracked_files,
              :HEAD, :branches,
              :previous_commit_contents

  def initialize(name)
    @name                     = name
    @commits                  = []
    @staged                   = []
    @unstaged                 = {}
    @untracked                = {}
    @modified_files           = []
    @tracked_files            = {}
    @branches                 = {:master => nil}
    @HEAD                     = :master
    @previous_commit_contents = {}
  end

  def new_file(path, content)
    f = File.new(self, path, content)
    untracked[f.path] = f
    f
  end

  def add(file)
    staged << file
    if tracked_files[file.path]
      tracked_files.delete(file.path)
    else
      untracked.delete(file.path)
    end
    unstaged.delete(file.path)
  end

  def commit(msg)
    file = staged.pop
    previous_commit_contents[file.path] = file.content
    modified_files << file
  end

  def file_updated(file)
    unstaged[file.path] = tracked_files.delete(file.path)
  end

  def branch(name, opts=nil)
    if opts == DELETE_FLAG
      branches.delete(name)
    else
      branches[name] = nil
    end
  end

  class File
    attr_reader :path

    def initialize(repo, path, content)
      @repo = repo
      @path = path
      @content = content
    end

    def content=(content)
      @repo.file_updated(self)
      @content = content
    end

    def content
      @content
    end

    def ==(other)
      if other.is_a?(Repository::File)
        other.path == path
      else
        raise RuntimeError, "can't compare #{self} to a non repo file"
      end
    end
  end

end
