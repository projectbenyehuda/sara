require 'rails_helper'

describe ProjectsController do
  describe 'Collection Actions' do
    describe '#index' do
      subject! { get :index }
      it { is_expected.to be_successful }
    end

    describe '#create' do
      subject(:call) { post :create, params: { project: project_attrs } }

      context 'when project attributes are valid' do
        let(:project_attrs) { { title: 'New Project' } }

        it 'creates new project record and redirects to its page' do
          expect { call }.to change { Project.count }.by(1)
          p = Project.order(id: :desc).first
          expect(p).to have_attributes(title: 'New Project')
          expect(response).to redirect_to p
        end
      end

      context 'when project attributes are invalid' do
        let(:project_attrs) { { title: ' ' } }

        it 'redirects to index action' do
          expect { call }.to_not change { Project.count }
          expect(response).to redirect_to projects_path
        end
      end
    end
  end

  describe 'Member Actions' do
    let!(:project) { create(:project, title: 'Project Title') }

    describe '#destroy' do
      subject(:call) { delete :destroy, params: { id: project.id } }

      it 'destroys record' do
        expect { call }.to change { Project.count }.by(-1)
        expect { project.reload }.to raise_error ActiveRecord::RecordNotFound
        expect(response).to redirect_to projects_path
      end
    end

    describe '#edit' do
      subject { get :edit, params: { id: project.id } }

      it { is_expected.to render_template :edit }
    end

    describe '#update' do
      subject! { patch :update, params: { id: project.id, project: { title: new_title } } }

      context 'when new title is valid' do
        let(:new_title) { 'New Title' }

        it 'saves changes and redirects to project page' do
          expect(response).to redirect_to project
          project.reload
          expect(project).to have_attributes(title: 'New Title')
        end
      end

      context 'when new title is invalid' do
        let(:new_title) { ' ' }

        it 'does not saves changes and re-renders edit view' do
          expect(response).to have_http_status(:unprocessable_entity)
          project.reload
          expect(project).to have_attributes(title: 'Project Title')
        end
      end
    end

    describe '#show' do
      subject { get :show, params: { id: project.id } }

      it { is_expected.to be_successful }
    end
  end
end
