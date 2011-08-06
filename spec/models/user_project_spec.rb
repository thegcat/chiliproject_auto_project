require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  subject {lambda {user.save}}
  let(:role) {Factory.create :role}

  describe "when an exisiting user is updated" do
    let(:user) {Factory.create :user}
    
    describe "with no status change" do
      # when calling user for the first time, it actually gets created and goes through the whole
      # create a new project for the user thing, thus we need the role stubbing here too
      before do
        roles = [role]
        roles.stub!(:find_by_id).and_return role
        Role.stub!(:givable).and_return roles
      end
      
      it "should not change the user's projects" do
        subject.should_not change user, :projects
      end
    end

    describe "with a status change to active" do
      before do
        user.status = User::STATUS_ACTIVE
      end

      describe "from registered" do
        let(:user) {Factory.create :user, :status => User::STATUS_REGISTERED}

        describe "if a project with the same identifier as the user's login doesn't exist yet" do
          before do
            roles = [role]
            roles.stub!(:find_by_id).and_return role
            Role.stub!(:givable).and_return roles
          end

          it "should add the user to the project" do
            subject.should change(user.projects, :count).by(1)
          end
        end

        describe "if a project with the same identifier as the user's login already exists" do
          before do
            Factory.create :project, :identifier => user.login
          end

          it "should not change the user's projects" do
            subject.should_not change user, :projects
          end
        end
      end

      describe "from locked" do
        let(:user) {Factory.create :user, :status => User::STATUS_LOCKED}

        it "should not change the user's projects" do
          subject.should_not change user, :projects
        end
      end
    end
  end

  describe "when a new user is created" do
    let(:user) {Factory.build :user, :status => nil}

    describe "with an active status" do
      before do
        user.status = User::STATUS_ACTIVE
      end

      describe "if a project with the same identifier as the user's login doesn't exist yet" do
        before do
          roles = [role]
          roles.stub!(:find_by_id).and_return role
          Role.stub!(:givable).and_return roles
        end

        it "should add the user to the project" do
          subject.should change(user.projects, :count).by(1)
        end
      end

      describe "if a project with the same identifier as the user's login already exists" do
        before do
          Factory.create :project, :identifier => user.login
        end

        it "should not change the user's projects" do
          subject.should_not change user, :projects
        end
      end
    end

    describe "with an registered status" do
      before do
        user.status = User::STATUS_REGISTERED
      end

      it "should not change the user's projects" do
        subject.should_not change user, :projects
      end
    end
  end
end

describe Project do
  let(:role) {Factory.create :role}
  
  before do
    roles = [role]
    roles.stub!(:find_by_id).and_return role
    Role.stub!(:givable).and_return roles
  end
  
  describe "when a project is auto-created for a user" do
    let(:user) {Factory.create :user}
    subject {user.projects[0]}
    
    it "then the project's name should be the user's name" do
      subject.name.should eql user.name
    end
    
    it "then the project's identifier should be the user's login" do
      subject.identifier.should eql user.login
    end
    
    it "then the project should not be public" do
      subject.is_public.should_not be_true
    end
  end
end