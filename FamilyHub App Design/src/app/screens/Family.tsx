import { useState } from "react";
import { useAuth } from "@/app/contexts/AuthContext";
import { useRelationships, allFamilyMembers, RelationType } from "@/app/contexts/RelationshipContext";
import { Card } from "@/app/components/ui/card";
import { Button } from "@/app/components/ui/button";
import { Badge } from "@/app/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/app/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/app/components/ui/select";
import { Users, Edit, Trash2, Plus, Heart, Shield } from "lucide-react";

export default function Family() {
  const { user } = useAuth();
  const { getFamilyMembers, addRelationship, updateRelationship, removeRelationship, isCloseFamily } = useRelationships();
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [selectedMember, setSelectedMember] = useState<number | null>(null);
  const [selectedRelation, setSelectedRelation] = useState<RelationType>("friend");
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);

  const getUserIdByEmail = (email: string): number => {
    const userMap: Record<string, number> = {
      "sarah@example.com": 1,
      "mike@example.com": 2,
      "emma@example.com": 3,
      "mary@example.com": 4,
    };
    return userMap[email] || 1;
  };

  const currentUserId = user ? getUserIdByEmail(user.email) : 0;
  const familyMembers = getFamilyMembers(currentUserId);
  const familyMemberIds = familyMembers.map((m) => m.id);
  const availableMembers = allFamilyMembers.filter(
    (m) => m.id !== currentUserId && !familyMemberIds.includes(m.id)
  );

  const relationOptions: { value: RelationType; label: string }[] = [
    { value: "mother", label: "Mother" },
    { value: "father", label: "Father" },
    { value: "daughter", label: "Daughter" },
    { value: "son", label: "Son" },
    { value: "sister", label: "Sister" },
    { value: "brother", label: "Brother" },
    { value: "wife", label: "Wife" },
    { value: "husband", label: "Husband" },
    { value: "grandmother", label: "Grandmother" },
    { value: "grandfather", label: "Grandfather" },
    { value: "granddaughter", label: "Granddaughter" },
    { value: "grandson", label: "Grandson" },
    { value: "aunt", label: "Aunt" },
    { value: "uncle", label: "Uncle" },
    { value: "niece", label: "Niece" },
    { value: "nephew", label: "Nephew" },
    { value: "cousin", label: "Cousin" },
    { value: "friend", label: "Friend" },
  ];

  const getRelationLabel = (relation: RelationType) => {
    return relationOptions.find((r) => r.value === relation)?.label || relation;
  };

  const handleOpenEditDialog = (memberId: number, currentRelation: RelationType) => {
    setSelectedMember(memberId);
    setSelectedRelation(currentRelation);
    setIsEditDialogOpen(true);
  };

  const handleUpdateRelation = () => {
    if (selectedMember) {
      updateRelationship(selectedMember, selectedRelation);
      setIsEditDialogOpen(false);
      setSelectedMember(null);
    }
  };

  const handleRemoveRelation = (memberId: number) => {
    if (confirm("Are you sure you want to remove this relationship?")) {
      removeRelationship(memberId);
    }
  };

  const handleOpenAddDialog = () => {
    setSelectedMember(null);
    setSelectedRelation("friend");
    setIsAddDialogOpen(true);
  };

  const handleAddRelation = () => {
    if (selectedMember) {
      addRelationship(selectedMember, selectedRelation);
      setIsAddDialogOpen(false);
      setSelectedMember(null);
    }
  };

  const closeFamily = familyMembers.filter((m) => isCloseFamily(currentUserId, m.id));
  const friends = familyMembers.filter((m) => !isCloseFamily(currentUserId, m.id));

  return (
    <div className="flex flex-col h-full bg-gray-50">
      {/* Header */}
      <div className="bg-gradient-to-r from-purple-600 to-pink-600 text-white px-6 pt-12 pb-8">
        <div className="flex items-center gap-3 mb-2">
          <Users className="w-8 h-8" />
          <h1 className="text-2xl font-bold">Family & Friends</h1>
        </div>
        <p className="text-purple-100">
          Manage your family relationships and connections
        </p>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto px-6 py-6 space-y-6">
        {/* Close Family Section */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <Shield className="w-5 h-5 text-red-600" />
              <h2 className="text-lg font-semibold text-gray-900">
                Close Family ({closeFamily.length})
              </h2>
            </div>
            <Badge variant="secondary" className="bg-red-100 text-red-700">
              SOS Enabled
            </Badge>
          </div>
          <p className="text-sm text-gray-600 mb-4">
            Close family members will receive your SOS emergency alerts
          </p>
          <div className="space-y-3">
            {closeFamily.length === 0 ? (
              <Card className="p-6 text-center">
                <p className="text-gray-500">No close family members added yet</p>
              </Card>
            ) : (
              closeFamily.map((member) => (
                <Card key={member.id} className="p-4">
                  <div className="flex items-center gap-4">
                    <img
                      src={member.avatar}
                      alt={member.name}
                      className="w-12 h-12 rounded-full"
                    />
                    <div className="flex-1 min-w-0">
                      <h3 className="font-semibold text-gray-900">{member.name}</h3>
                      <Badge
                        variant="secondary"
                        className="bg-purple-100 text-purple-700 capitalize"
                      >
                        {getRelationLabel(member.relation)}
                      </Badge>
                    </div>
                    <div className="flex gap-2">
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleOpenEditDialog(member.id, member.relation)}
                      >
                        <Edit className="w-4 h-4" />
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        className="text-red-600 hover:text-red-700"
                        onClick={() => handleRemoveRelation(member.id)}
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </Card>
              ))
            )}
          </div>
        </div>

        {/* Friends & Extended Family Section */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <Heart className="w-5 h-5 text-blue-600" />
              <h2 className="text-lg font-semibold text-gray-900">
                Friends & Extended Family ({friends.length})
              </h2>
            </div>
          </div>
          <div className="space-y-3">
            {friends.length === 0 ? (
              <Card className="p-6 text-center">
                <p className="text-gray-500">No friends or extended family added yet</p>
              </Card>
            ) : (
              friends.map((member) => (
                <Card key={member.id} className="p-4">
                  <div className="flex items-center gap-4">
                    <img
                      src={member.avatar}
                      alt={member.name}
                      className="w-12 h-12 rounded-full"
                    />
                    <div className="flex-1 min-w-0">
                      <h3 className="font-semibold text-gray-900">{member.name}</h3>
                      <Badge
                        variant="secondary"
                        className="bg-blue-100 text-blue-700 capitalize"
                      >
                        {getRelationLabel(member.relation)}
                      </Badge>
                    </div>
                    <div className="flex gap-2">
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleOpenEditDialog(member.id, member.relation)}
                      >
                        <Edit className="w-4 h-4" />
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        className="text-red-600 hover:text-red-700"
                        onClick={() => handleRemoveRelation(member.id)}
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </Card>
              ))
            )}
          </div>
        </div>

        {/* Add Member Button */}
        {availableMembers.length > 0 && (
          <Button className="w-full gap-2" onClick={handleOpenAddDialog}>
            <Plus className="w-5 h-5" />
            Add Family Member or Friend
          </Button>
        )}
      </div>

      {/* Edit Relationship Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Edit Relationship</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div>
              <label className="text-sm font-medium text-gray-700 mb-2 block">
                Relationship Type
              </label>
              <Select value={selectedRelation} onValueChange={(value) => setSelectedRelation(value as RelationType)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {relationOptions.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsEditDialogOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleUpdateRelation}>Save Changes</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Add Relationship Dialog */}
      <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Add Family Member or Friend</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div>
              <label className="text-sm font-medium text-gray-700 mb-2 block">
                Select Person
              </label>
              <Select value={selectedMember?.toString()} onValueChange={(value) => setSelectedMember(parseInt(value))}>
                <SelectTrigger>
                  <SelectValue placeholder="Choose a person" />
                </SelectTrigger>
                <SelectContent>
                  {availableMembers.map((member) => (
                    <SelectItem key={member.id} value={member.id.toString()}>
                      {member.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <label className="text-sm font-medium text-gray-700 mb-2 block">
                Relationship Type
              </label>
              <Select value={selectedRelation} onValueChange={(value) => setSelectedRelation(value as RelationType)}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {relationOptions.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsAddDialogOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleAddRelation} disabled={!selectedMember}>
              Add Relationship
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
