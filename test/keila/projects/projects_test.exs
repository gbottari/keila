defmodule Keila.ProjectsTest do
  use ExUnit.Case, async: true
  import Keila.Factory

  alias Keila.{Projects, Auth, Repo}
  alias Projects.Project

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  @tag :projects
  test "Creating a project also creates an Auth.Group and adds user to it" do
    _root = insert!(:group)
    user = insert!(:user)
    params = %{"name" => "My Project"}
    assert {:ok, project = %Project{}} = Projects.create_project(user.id, params)
    assert [group] = Auth.list_user_groups(user.id)
    assert project.group_id == group.id
  end

  @tag :projects
  test "When creating a project fails, Auth.Group creation is rolled back" do
    _root = insert!(:group)
    user = insert!(:user)
    assert {:error, %Ecto.Changeset{data: %Project{}}} = Projects.create_project(user.id, %{})
    assert [] = Auth.list_user_groups(user.id)
  end

  @tag :projects
  test "Update project name" do
    group = insert!(:group)
    project = insert!(:project, group: group)
    name = "New Project Name"
    assert {:ok, %Project{name: ^name}} = Projects.update_project(project.id, %{name: name})
  end

  @tag :projects
  test "Delete project is idempotent" do
    _root = insert!(:group)
    user = insert!(:user)
    {:ok, project} = Projects.create_project(user.id, %{"name" => "My Project"})
    assert :ok = Projects.delete_project(project.id)
    assert [] = Auth.list_user_groups(user.id)
  end
end