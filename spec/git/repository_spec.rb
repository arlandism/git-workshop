require 'spec_helper'

describe Repository do
  let(:repo) { Repository.new 'name', 'owner' }

  it 'has an owner and a name' do
    expect(repo.name).to eq 'name'
    expect(repo.owner).to eq 'owner'
  end

  it 'starts with an empty list of commits and no files' do
    expect(repo.commits).to be_empty
    expect(repo.working_directory[:staged]).to be_empty
    expect(repo.working_directory[:unstaged]).to be_empty
    expect(repo.working_directory[:untracked]).to be_empty
  end

  describe '#add' do
    it 'starts tracking files' do
      file = repo.new_file '/file/path', 'content'

      expect(repo.working_directory[:staged].length).to be 0
      expect(repo.working_directory[:unstaged].length).to be 0
      expect(repo.working_directory[:untracked].length).to be 1

      repo.add file

      expect(repo.working_directory[:staged].length).to be 1
      expect(repo.working_directory[:unstaged].length).to be 0
      expect(repo.working_directory[:untracked].length).to be 0
    end

    xit 'knows which files have been modified' do
      file = repo.new_file '/file/path', 'content'
      repo.add file
      file.content = 'new content'

      expect(repo.modified_files).to include file
    end
  end

  describe 'branches' do
    it 'starts with a master branch that has no commits' do
      expect(repo.branches[:master]).to be_nil
    end

    it 'has a current branch' do
      expect(repo.current_branch).to eq :master
    end

    it 'can create a new branch' do
      repo.new_branch 'feature'

      expect(repo.branches).to include :master
      expect(repo.branches).to include :feature
    end
  end

  describe '#commit' do
    let(:tree) {
      [
       Git::File.new('/first/file', 'content'),
       Git::File.new('/second/file', 'content')
      ]
    }
    let(:first_commit)  { Git::Commit.new tree, 'author' }
    let(:second_commit) { Git::Commit.new tree << Git::File.new('/third/file', 'content'), 'author' }

    it 'records the contents of tracked files so it can determine when they are modified' do
      path = '/first/file'
      repo.working_directory[:staged] = [Git::File.new(path, 'content')]
      repo.commit

      expect(repo.previous_commit_contents[path]).to eq 'content'
    end

    xit 'creates a commit of the staged files' do
    end

    xit 'keeps track of all commits' do
      repo.add_commit(first_commit)
      repo.add_commit(second_commit)

      expect(repo.commits).to include first_commit
      expect(repo.commits).to include second_commit
    end

    xit 'adds commits to the current branch' do
      repo.add_commit(first_commit)
      expect(repo.branches[:master]).to eq first_commit

      repo.add_commit(second_commit)
      expect(repo.branches[:master]).to eq second_commit
    end

    xit 'keeps track of the parent commit' do
      repo.add_commit(first_commit)
      repo.add_commit(second_commit)

      expect(second_commit.parents).to include first_commit
    end
  end
end
