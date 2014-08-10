require 'git/repository'

module Git
  class << self
    attr_accessor :repositories, :current_repo

    def init(name, owner)
      repo = Repository.new name, owner
      @repositories << repo
      self.current_repo = repo
      repo
    end

    def add(file)
      current_repo.working_directory[:untracked].delete file
      current_repo.working_directory[:staged].push file
    end

    def commit
      commit_files = current_repo.working_directory[:staged]
      clear_staged_files
      current_repo.add_commit commit_files
    end

    def checkout(repo)
      clear_staged_files
    end

    def cd(repo_name)
      self.current_repo = repositories.find { |repo| repo.name == repo_name }
    end

    def clear_staged_files
      current_repo.working_directory[:staged] = []
    end

  end
end
